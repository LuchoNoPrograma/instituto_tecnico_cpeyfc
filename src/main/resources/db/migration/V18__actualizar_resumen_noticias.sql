-- V18: Actualizar resumen de noticias que no tienen resumen generado
-- Fecha: 2025-11-10
-- Descripción: Asegura que todas las noticias existentes tengan el campo resumen
--              poblado con texto plano extraído del contenido HTML

-- Actualizar noticias que tienen contenido pero no tienen resumen
UPDATE pub_noticia
SET resumen = extraer_texto_de_html(contenido)
WHERE contenido IS NOT NULL
  AND contenido != ''
  AND (resumen IS NULL OR resumen = '' OR resumen = contenido);

-- Verificar que el trigger sigue activo
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'trigger_generar_resumen'
      AND tgrelid = 'pub_noticia'::regclass
  ) THEN
    RAISE NOTICE 'Recreando trigger trigger_generar_resumen';

    CREATE TRIGGER trigger_generar_resumen
      BEFORE INSERT OR UPDATE OF contenido ON pub_noticia
      FOR EACH ROW
      EXECUTE FUNCTION trigger_generar_resumen();
  END IF;
END $$;

-- Log de registros actualizados
DO $$
DECLARE
  total_actualizados INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO total_actualizados
  FROM pub_noticia
  WHERE resumen IS NOT NULL
    AND resumen != '';

  RAISE NOTICE 'Total de noticias con resumen: %', total_actualizados;
END $$;
