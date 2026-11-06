# Avisos por correo (gratis, con Gmail)
1. Cuenta de Google > Seguridad > Verificación en dos pasos (activar) > Contraseñas de aplicaciones > crear una llamada "avisos". Copia las 16 letras.
2. Supabase > Edge Functions > Deploy a new function > nombre `avisos` > pegar el contenido de index.ts > Deploy.
3. Supabase > Edge Functions > Secrets: GMAIL_USER (tu correo), GMAIL_APP_PASSWORD (las 16 letras, sin espacios), WEBHOOK_SECRET (cualquier texto largo).
4. Supabase > Database > Webhooks > Create: tabla likes, eventos Insert y Update, tipo Supabase Edge Functions, función avisos, y una cabecera HTTP `x-webhook-secret` con el mismo texto del paso 3.
