-- ============================================================================
-- MIGRACIÓN: Triggers del Sistema Académico CPEyFP
-- Versión: V22
-- Descripción: Triggers para auditoría, validaciones, cálculos automáticos
--              y lógica de negocio del sistema académico
-- Autor: CPEyFP Dev Team
-- Fecha: 2025-01-12
-- ============================================================================

-- ============================================================================
-- SECCIÓN 1: TRIGGERS DE AUDITORÍA (UPDATE FECHA_MOD Y USER_MOD)
-- ============================================================================

-- Función genérica para actualizar fecha_mod
CREATE OR REPLACE FUNCTION fn_actualizar_auditoria_mod()
RETURNS TRIGGER AS $$
BEGIN
  NEW.fecha_mod := NOW();
  -- user_mod se debe establecer desde la aplicación
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_actualizar_auditoria_mod IS 'Actualiza automáticamente fecha_mod en UPDATE';

-- Aplicar trigger a todas las tablas con auditoría
CREATE TRIGGER trg_aca_gestion_mod BEFORE UPDATE ON aca_gestion
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_aca_periodo_mod BEFORE UPDATE ON aca_periodo
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_aca_programa_mod BEFORE UPDATE ON aca_programa
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_aca_programa_aprobado_mod BEFORE UPDATE ON aca_programa_aprobado
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_aca_colegio_mod BEFORE UPDATE ON aca_colegio
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_aca_tipo_estudiante_mod BEFORE UPDATE ON aca_tipo_estudiante
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_ins_grupo_mod BEFORE UPDATE ON ins_grupo
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_ins_matricula_mod BEFORE UPDATE ON ins_matricula
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_prs_persona_mod BEFORE UPDATE ON prs_persona
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_fin_arancel_mod BEFORE UPDATE ON fin_arancel
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_fin_convenio_mod BEFORE UPDATE ON fin_convenio
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_fin_obligacion_pago_mod BEFORE UPDATE ON fin_obligacion_pago
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_eje_docente_mod BEFORE UPDATE ON eje_docente
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_eje_cronograma_modulo_mod BEFORE UPDATE ON eje_cronograma_modulo
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_eje_calificacion_mod BEFORE UPDATE ON eje_calificacion
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

CREATE TRIGGER trg_aca_certificado_emitido_mod BEFORE UPDATE ON aca_certificado_emitido
  FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();

-- ============================================================================
-- SECCIÓN 2: TRIGGER CALCULAR NOTA FINAL POR COMPETENCIAS
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calcular_nota_final_competencias()
RETURNS TRIGGER AS $$
DECLARE
  v_promedio NUMERIC(5,2);
  v_total_areas INTEGER;
BEGIN
  -- Calcular promedio de todas las áreas de evaluación
  SELECT
    AVG(dc.nota_final_area),
    COUNT(*)
  INTO v_promedio, v_total_areas
  FROM eje_detalle_calificacion dc
  WHERE dc.id_eje_calificacion = NEW.id_eje_calificacion
    AND dc.estado_detalle_calificacion = 'ACTIVO';

  -- Si hay detalles, actualizar nota en eje_calificacion
  IF v_total_areas > 0 THEN
    UPDATE eje_calificacion
    SET nota = v_promedio,
        nota_ponderada = v_promedio
    WHERE id_eje_calificacion = NEW.id_eje_calificacion;

    -- También actualizar en eje_programacion
    UPDATE eje_programacion ep
    SET nota_final = v_promedio
    FROM eje_calificacion ec
    WHERE ec.id_eje_programacion = ep.id_eje_programacion
      AND ec.id_eje_calificacion = NEW.id_eje_calificacion;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_calcular_nota_final_competencias IS 'Calcula nota final promediando competencias';

CREATE TRIGGER trg_calcular_nota_competencias
  AFTER INSERT OR UPDATE ON eje_detalle_calificacion
  FOR EACH ROW
  WHEN (NEW.estado_detalle_calificacion = 'ACTIVO')
  EXECUTE FUNCTION fn_calcular_nota_final_competencias();

-- ============================================================================
-- SECCIÓN 3: TRIGGER ACTUALIZAR SALDO PENDIENTE
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_actualizar_saldo_pendiente()
RETURNS TRIGGER AS $$
DECLARE
  v_total_pagado NUMERIC(10,2);
BEGIN
  -- Calcular total pagado
  SELECT COALESCE(SUM(dp.monto_pago), 0)
  INTO v_total_pagado
  FROM fin_detalle_pago dp
  WHERE dp.id_fin_obligacion_pago = NEW.id_fin_obligacion_pago
    AND dp.estado_detalle_pago != 'ELIMINADO';

  -- Actualizar saldo pendiente
  UPDATE fin_obligacion_pago
  SET saldo_pendiente = GREATEST(monto_final - v_total_pagado, 0),
      estado_obligacion_pago = CASE
        WHEN GREATEST(monto_final - v_total_pagado, 0) = 0 THEN 'PAGADO'
        WHEN GREATEST(monto_final - v_total_pagado, 0) < monto_final THEN 'PAGO_PARCIAL'
        ELSE 'PENDIENTE'
      END
  WHERE id_fin_obligacion_pago = NEW.id_fin_obligacion_pago;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_actualizar_saldo_pendiente IS 'Actualiza saldo pendiente después de un pago';

CREATE TRIGGER trg_actualizar_saldo
  AFTER INSERT OR UPDATE ON fin_detalle_pago
  FOR EACH ROW
  WHEN (NEW.estado_detalle_pago != 'ELIMINADO')
  EXECUTE FUNCTION fn_actualizar_saldo_pendiente();

-- ============================================================================
-- SECCIÓN 4: TRIGGER VALIDAR FECHAS DE INSCRIPCIÓN
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_fechas_inscripcion()
RETURNS TRIGGER AS $$
DECLARE
  v_periodo_inicio DATE;
  v_periodo_fin DATE;
BEGIN
  -- Si tiene periodo asignado, validar que las fechas estén dentro del periodo
  IF NEW.id_aca_periodo IS NOT NULL THEN
    SELECT fecha_inicio, fecha_fin
    INTO v_periodo_inicio, v_periodo_fin
    FROM aca_periodo
    WHERE id_aca_periodo = NEW.id_aca_periodo;

    IF NEW.fecha_inicio_inscripciones IS NOT NULL
       AND NEW.fecha_inicio_inscripciones < v_periodo_inicio THEN
      RAISE EXCEPTION 'Fecha de inicio de inscripciones no puede ser anterior al inicio del periodo';
    END IF;

    IF NEW.fecha_fin_inscripciones IS NOT NULL
       AND NEW.fecha_fin_inscripciones > v_periodo_fin THEN
      RAISE EXCEPTION 'Fecha de fin de inscripciones no puede ser posterior al fin del periodo';
    END IF;
  END IF;

  -- Validar que fecha_fin sea posterior a fecha_inicio
  IF NEW.fecha_inicio_inscripciones IS NOT NULL
     AND NEW.fecha_fin_inscripciones IS NOT NULL
     AND NEW.fecha_fin_inscripciones < NEW.fecha_inicio_inscripciones THEN
    RAISE EXCEPTION 'Fecha de fin de inscripciones debe ser posterior a fecha de inicio';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_fechas_inscripcion IS 'Valida fechas de inscripción dentro del periodo';

CREATE TRIGGER trg_validar_fechas_inscripcion
  BEFORE INSERT OR UPDATE ON eje_cronograma_modulo
  FOR EACH ROW
  EXECUTE FUNCTION fn_validar_fechas_inscripcion();

-- ============================================================================
-- SECCIÓN 5: TRIGGER GENERAR NÚMERO DE CERTIFICADO
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_generar_numero_certificado()
RETURNS TRIGGER AS $$
DECLARE
  v_anio VARCHAR(4);
  v_consecutivo INTEGER;
  v_numero_certificado VARCHAR(50);
BEGIN
  -- Si ya tiene número, no hacer nada
  IF NEW.numero_certificado IS NOT NULL AND NEW.numero_certificado != '' THEN
    RETURN NEW;
  END IF;

  v_anio := EXTRACT(YEAR FROM CURRENT_DATE)::VARCHAR;

  -- Obtener último consecutivo del año
  SELECT COALESCE(MAX(
    CAST(SUBSTRING(numero_certificado FROM '[0-9]+$') AS INTEGER)
  ), 0) + 1
  INTO v_consecutivo
  FROM aca_certificado_emitido
  WHERE numero_certificado LIKE 'CERT-' || v_anio || '-%';

  -- Generar número con formato: CERT-2025-00001
  v_numero_certificado := 'CERT-' || v_anio || '-' || LPAD(v_consecutivo::TEXT, 5, '0');

  NEW.numero_certificado := v_numero_certificado;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_generar_numero_certificado IS 'Genera número único de certificado automáticamente';

CREATE TRIGGER trg_generar_numero_certificado
  BEFORE INSERT ON aca_certificado_emitido
  FOR EACH ROW
  EXECUTE FUNCTION fn_generar_numero_certificado();

-- ============================================================================
-- SECCIÓN 6: TRIGGER VALIDAR ARANCEL VIGENTE EN MATRÍCULA
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_arancel_vigente()
RETURNS TRIGGER AS $$
DECLARE
  v_estado_arancel VARCHAR(35);
  v_fecha_fin DATE;
BEGIN
  -- Si no tiene arancel aplicado, saltear
  IF NEW.id_fin_arancel_aplicado IS NULL THEN
    RETURN NEW;
  END IF;

  -- Validar que el arancel esté vigente
  SELECT estado_arancel, fecha_fin_vigencia
  INTO v_estado_arancel, v_fecha_fin
  FROM fin_arancel
  WHERE id_fin_arancel = NEW.id_fin_arancel_aplicado;

  IF v_estado_arancel != 'ACTIVO' THEN
    RAISE EXCEPTION 'El arancel seleccionado no está activo';
  END IF;

  IF v_fecha_fin IS NOT NULL AND v_fecha_fin < CURRENT_DATE THEN
    RAISE EXCEPTION 'El arancel seleccionado ya no está vigente';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_arancel_vigente IS 'Valida que el arancel esté vigente al matricular';

CREATE TRIGGER trg_validar_arancel_matricula
  BEFORE INSERT OR UPDATE ON ins_matricula
  FOR EACH ROW
  WHEN (NEW.id_fin_arancel_aplicado IS NOT NULL)
  EXECUTE FUNCTION fn_validar_arancel_vigente();

-- ============================================================================
-- SECCIÓN 7: TRIGGER VALIDAR CONVENIO VIGENTE EN MATRÍCULA
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_convenio_vigente()
RETURNS TRIGGER AS $$
DECLARE
  v_estado_convenio VARCHAR(35);
  v_fecha_fin DATE;
  v_id_colegio INTEGER;
  v_existe_relacion BOOLEAN;
BEGIN
  -- Si no tiene convenio aplicado, saltear
  IF NEW.id_fin_convenio_aplicado IS NULL THEN
    RETURN NEW;
  END IF;

  -- Validar que el convenio esté vigente
  SELECT estado_convenio, fecha_fin_vigencia
  INTO v_estado_convenio, v_fecha_fin
  FROM fin_convenio
  WHERE id_fin_convenio = NEW.id_fin_convenio_aplicado;

  IF v_estado_convenio != 'ACTIVO' THEN
    RAISE EXCEPTION 'El convenio seleccionado no está activo';
  END IF;

  IF v_fecha_fin IS NOT NULL AND v_fecha_fin < CURRENT_DATE THEN
    RAISE EXCEPTION 'El convenio seleccionado ya no está vigente';
  END IF;

  -- Validar que el colegio de procedencia tenga el convenio
  SELECT p.id_aca_colegio_procedencia
  INTO v_id_colegio
  FROM prs_persona p
  WHERE p.id_prs_persona = NEW.id_prs_persona;

  IF v_id_colegio IS NOT NULL THEN
    SELECT EXISTS(
      SELECT 1
      FROM fin_colegio_convenio cc
      WHERE cc.id_aca_colegio = v_id_colegio
        AND cc.id_fin_convenio = NEW.id_fin_convenio_aplicado
        AND cc.estado_colegio_convenio = 'ACTIVO'
    ) INTO v_existe_relacion;

    IF NOT v_existe_relacion THEN
      RAISE EXCEPTION 'El colegio de procedencia no tiene convenio activo';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_convenio_vigente IS 'Valida que el convenio esté vigente y asociado al colegio';

CREATE TRIGGER trg_validar_convenio_matricula
  BEFORE INSERT OR UPDATE ON ins_matricula
  FOR EACH ROW
  WHEN (NEW.id_fin_convenio_aplicado IS NOT NULL)
  EXECUTE FUNCTION fn_validar_convenio_vigente();

-- ============================================================================
-- SECCIÓN 8: TRIGGER ACTUALIZAR ESTADO DE GRUPO POR FECHAS
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_actualizar_estado_grupo()
RETURNS TRIGGER AS $$
BEGIN
  -- Actualizar estado basándose en fechas
  IF NEW.fecha_inicio IS NOT NULL AND NEW.fecha_fin IS NOT NULL THEN
    IF CURRENT_DATE < NEW.fecha_inicio_inscripcion THEN
      NEW.estado_grupo := 'PROGRAMADO';
    ELSIF CURRENT_DATE BETWEEN NEW.fecha_inicio_inscripcion AND NEW.fecha_fin_inscripcion THEN
      NEW.estado_grupo := 'EN OFERTA';
    ELSIF CURRENT_DATE BETWEEN NEW.fecha_inicio AND NEW.fecha_fin THEN
      NEW.estado_grupo := 'EN EJECUCION';
    ELSIF CURRENT_DATE > NEW.fecha_fin THEN
      NEW.estado_grupo := 'FINALIZADO';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_actualizar_estado_grupo IS 'Actualiza estado del grupo según fechas';

-- Nota: Este trigger se activa en INSERT pero se podría ejecutar periódicamente
CREATE TRIGGER trg_actualizar_estado_grupo
  BEFORE INSERT OR UPDATE ON ins_grupo
  FOR EACH ROW
  WHEN (NEW.fecha_inicio IS NOT NULL AND NEW.fecha_fin IS NOT NULL)
  EXECUTE FUNCTION fn_actualizar_estado_grupo();

-- ============================================================================
-- SECCIÓN 9: TRIGGER VERIFICAR ELIMINACIÓN LÓGICA
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_prevenir_eliminacion_fisica()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'No se permite eliminación física. Use eliminación lógica (estado = ELIMINADO)';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_prevenir_eliminacion_fisica IS 'Previene eliminación física, fuerza uso de soft delete';

-- Aplicar a tablas críticas (opcional, comentado por defecto)
-- CREATE TRIGGER trg_prevenir_delete_matricula BEFORE DELETE ON ins_matricula
--   FOR EACH ROW EXECUTE FUNCTION fn_prevenir_eliminacion_fisica();

-- CREATE TRIGGER trg_prevenir_delete_calificacion BEFORE DELETE ON eje_calificacion
--   FOR EACH ROW EXECUTE FUNCTION fn_prevenir_eliminacion_fisica();

-- ============================================================================
-- SECCIÓN 10: TRIGGER VALIDAR PROGRESIÓN DE ESTUDIANTE
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_progresion_estudiante()
RETURNS TRIGGER AS $$
DECLARE
  v_nota_minima INTEGER := 51; -- Nota mínima de aprobación
BEGIN
  -- Si aprobó (nota >= 51), marcar debe_repetir = false
  IF NEW.nota IS NOT NULL AND NEW.nota >= v_nota_minima THEN
    NEW.debe_repetir := false;
  ELSIF NEW.nota IS NOT NULL AND NEW.nota < v_nota_minima THEN
    NEW.debe_repetir := true;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_progresion_estudiante IS 'Determina si estudiante debe repetir módulo';

CREATE TRIGGER trg_validar_progresion
  BEFORE INSERT OR UPDATE ON eje_calificacion
  FOR EACH ROW
  WHEN (NEW.nota IS NOT NULL)
  EXECUTE FUNCTION fn_validar_progresion_estudiante();

-- ============================================================================
-- SECCIÓN 11: TRIGGER GENERAR HASH DE VERIFICACIÓN CERTIFICADO
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_generar_hash_verificacion()
RETURNS TRIGGER AS $$
DECLARE
  v_datos_hash TEXT;
BEGIN
  -- Generar hash con datos del certificado
  v_datos_hash := NEW.numero_certificado ||
                  NEW.id_prs_persona::TEXT ||
                  NEW.id_aca_certificacion_programa::TEXT ||
                  NEW.fecha_emision::TEXT;

  -- Generar hash MD5
  NEW.hash_verificacion := MD5(v_datos_hash);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_generar_hash_verificacion IS 'Genera hash de verificación para certificado';

CREATE TRIGGER trg_generar_hash_certificado
  BEFORE INSERT ON aca_certificado_emitido
  FOR EACH ROW
  EXECUTE FUNCTION fn_generar_hash_verificacion();

-- ============================================================================
-- SECCIÓN 12: TRIGGER VALIDAR PERIODO ACADÉMICO ACTIVO
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_validar_periodo_activo()
RETURNS TRIGGER AS $$
DECLARE
  v_estado_periodo VARCHAR(35);
  v_estado_gestion VARCHAR(35);
BEGIN
  -- Validar que el periodo esté activo
  SELECT p.estado_periodo, g.estado_gestion
  INTO v_estado_periodo, v_estado_gestion
  FROM aca_periodo p
  JOIN aca_gestion g ON p.id_aca_gestion = g.id_aca_gestion
  WHERE p.id_aca_periodo = NEW.id_aca_periodo;

  IF v_estado_periodo = 'ELIMINADO' THEN
    RAISE EXCEPTION 'No se puede asignar un periodo eliminado';
  END IF;

  IF v_estado_gestion = 'CERRADO' OR v_estado_gestion = 'ELIMINADO' THEN
    RAISE EXCEPTION 'La gestión del periodo está cerrada o eliminada';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_periodo_activo IS 'Valida que el periodo y gestión estén activos';

CREATE TRIGGER trg_validar_periodo_cronograma
  BEFORE INSERT OR UPDATE ON eje_cronograma_modulo
  FOR EACH ROW
  WHEN (NEW.id_aca_periodo IS NOT NULL)
  EXECUTE FUNCTION fn_validar_periodo_activo();

-- ============================================================================
-- SECCIÓN 13: TRIGGER LOG DE CAMBIOS EN CALIFICACIONES
-- ============================================================================

-- Tabla para auditoría de calificaciones
CREATE TABLE IF NOT EXISTS eje_log_calificacion (
  id_eje_log_calificacion SERIAL PRIMARY KEY,
  id_eje_calificacion INTEGER NOT NULL,
  accion VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
  nota_anterior NUMERIC(5,2),
  nota_nueva NUMERIC(5,2),
  usuario_cambio INTEGER,
  fecha_cambio TIMESTAMP NOT NULL DEFAULT NOW(),
  observacion TEXT
);

COMMENT ON TABLE eje_log_calificacion IS 'Auditoría de cambios en calificaciones';

CREATE OR REPLACE FUNCTION fn_log_cambio_calificacion()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.nota IS DISTINCT FROM NEW.nota THEN
    INSERT INTO eje_log_calificacion (
      id_eje_calificacion,
      accion,
      nota_anterior,
      nota_nueva,
      usuario_cambio,
      observacion
    ) VALUES (
      NEW.id_eje_calificacion,
      'UPDATE',
      OLD.nota,
      NEW.nota,
      NEW.user_mod,
      'Cambio de nota'
    );
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO eje_log_calificacion (
      id_eje_calificacion,
      accion,
      nota_nueva,
      usuario_cambio,
      observacion
    ) VALUES (
      NEW.id_eje_calificacion,
      'INSERT',
      NEW.nota,
      NEW.user_reg,
      'Nota inicial'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_log_cambio_calificacion IS 'Registra cambios en calificaciones para auditoría';

CREATE TRIGGER trg_log_calificacion
  AFTER INSERT OR UPDATE ON eje_calificacion
  FOR EACH ROW
  EXECUTE FUNCTION fn_log_cambio_calificacion();

-- ============================================================================
-- FIN DE MIGRACIÓN
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '============================================================================';
  RAISE NOTICE 'MIGRACIÓN V22 COMPLETADA EXITOSAMENTE';
  RAISE NOTICE 'Se crearon los siguientes triggers:';
  RAISE NOTICE '';
  RAISE NOTICE 'AUDITORÍA:';
  RAISE NOTICE '- trg_*_mod: Actualización automática de fecha_mod en todas las tablas';
  RAISE NOTICE '';
  RAISE NOTICE 'CÁLCULOS AUTOMÁTICOS:';
  RAISE NOTICE '- trg_calcular_nota_competencias: Calcula nota final por competencias';
  RAISE NOTICE '- trg_actualizar_saldo: Actualiza saldo pendiente después de pagos';
  RAISE NOTICE '';
  RAISE NOTICE 'VALIDACIONES:';
  RAISE NOTICE '- trg_validar_fechas_inscripcion: Valida fechas dentro del periodo';
  RAISE NOTICE '- trg_validar_arancel_matricula: Valida vigencia de arancel';
  RAISE NOTICE '- trg_validar_convenio_matricula: Valida vigencia de convenio';
  RAISE NOTICE '- trg_validar_periodo_cronograma: Valida periodo activo';
  RAISE NOTICE '- trg_validar_progresion: Determina si estudiante repite';
  RAISE NOTICE '';
  RAISE NOTICE 'GENERACIÓN AUTOMÁTICA:';
  RAISE NOTICE '- trg_generar_numero_certificado: Genera número único de certificado';
  RAISE NOTICE '- trg_generar_hash_certificado: Genera hash de verificación';
  RAISE NOTICE '';
  RAISE NOTICE 'GESTIÓN DE ESTADOS:';
  RAISE NOTICE '- trg_actualizar_estado_grupo: Actualiza estado según fechas';
  RAISE NOTICE '';
  RAISE NOTICE 'AUDITORÍA ESPECIAL:';
  RAISE NOTICE '- trg_log_calificacion: Registra cambios en calificaciones';
  RAISE NOTICE '- Tabla: eje_log_calificacion (creada)';
  RAISE NOTICE '============================================================================';
END $$;
