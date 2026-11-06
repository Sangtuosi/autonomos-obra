// Edge Function "avisos": envía un correo cuando hay un contacto nuevo o una respuesta.
// Se activa con un Database Webhook sobre la tabla likes (INSERT y UPDATE).
// Secretos necesarios: GMAIL_USER, GMAIL_APP_PASSWORD, WEBHOOK_SECRET (y los de Supabase, que ya vienen puestos).
import { createClient } from "npm:@supabase/supabase-js@2";
import nodemailer from "npm:nodemailer@6";

const APP = "https://sangtuosi.github.io/autonomos-obra/";
const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const mail = nodemailer.createTransport({
  service: "gmail",
  auth: { user: Deno.env.get("GMAIL_USER"), pass: Deno.env.get("GMAIL_APP_PASSWORD") },
});

async function emailOf(id: string) {
  const { data } = await sb.auth.admin.getUserById(id);
  return data?.user?.email || "";
}

function html(title: string, text: string) {
  return `<div style="font-family:system-ui,sans-serif;max-width:480px;margin:auto;padding:20px">
  <h2 style="color:#e8641a">${title}</h2><p style="font-size:16px;line-height:1.5">${text}</p>
  <p><a href="${APP}" style="background:#e8641a;color:#fff;padding:12px 20px;border-radius:10px;text-decoration:none;display:inline-block">Abrir la app</a></p></div>`;
}

Deno.serve(async (req) => {
  if (req.headers.get("x-webhook-secret") !== Deno.env.get("WEBHOOK_SECRET")) return new Response("no", { status: 401 });
  const ev = await req.json();
  const r = ev.record || {};
  const old = ev.old_record || {};
  let to = "", subject = "", title = "", text = "";

  if (ev.type === "INSERT") {
    if (r.from_autonomo) {
      const { data: a } = await sb.from("profiles").select("name").eq("id", r.autonomo_id).single();
      to = await emailOf(r.company_id);
      subject = "Un autónomo quiere trabajar con vosotros";
      title = "Tienes un contacto nuevo";
      text = `${a?.name || "Un autónomo"} se ha interesado por tu empresa. Entra para ver su perfil.`;
    } else {
      const { data: c } = await sb.from("companies").select("name").eq("id", r.company_id).single();
      to = await emailOf(r.autonomo_id);
      subject = "Una empresa se ha fijado en ti";
      title = "Te han marcado";
      text = `${c?.name || "Una empresa"} se ha interesado por tu perfil.${r.job ? " Nota: " + r.job : ""} Entra para aceptar o rechazar.`;
    }
  } else if (ev.type === "UPDATE" && old.status !== r.status && r.status !== "pending") {
    const accepted = r.status === "accepted";
    if (r.from_autonomo) {
      const { data: c } = await sb.from("companies").select("name").eq("id", r.company_id).single();
      to = await emailOf(r.autonomo_id);
      subject = accepted ? "Una empresa ha aceptado tu contacto" : "Respuesta de una empresa";
      title = accepted ? "Contacto aceptado" : "Respuesta recibida";
      text = accepted ? `${c?.name || "La empresa"} ha aceptado. Ya puedes llamar o escribir.` : `${c?.name || "La empresa"} no puede ahora.`;
    } else {
      const { data: a } = await sb.from("profiles").select("name").eq("id", r.autonomo_id).single();
      to = await emailOf(r.company_id);
      subject = accepted ? "Un autónomo ha aceptado tu contacto" : "Respuesta de un autónomo";
      title = accepted ? "Contacto aceptado" : "Respuesta recibida";
      text = accepted ? `${a?.name || "El autónomo"} ha aceptado. Ya puedes llamar o escribir.` : `${a?.name || "El autónomo"} no puede ahora.`;
    }
  }
  if (!to) return new Response("nada que enviar");
  await mail.sendMail({ from: `"Avisos" <${Deno.env.get("GMAIL_USER")}>`, to, subject, html: html(title, text) });
  return new Response("ok");
});
