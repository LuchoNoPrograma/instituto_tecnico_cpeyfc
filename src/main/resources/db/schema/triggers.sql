-- ============================================
-- TRIGGERS
-- ============================================

CREATE TRIGGER trg_aca_certificado_emitido_mod BEFORE UPDATE ON public.aca_certificado_emitido FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_generar_hash_certificado BEFORE INSERT ON public.aca_certificado_emitido FOR EACH ROW EXECUTE FUNCTION fn_generar_hash_verificacion();


CREATE TRIGGER trg_generar_numero_certificado BEFORE INSERT ON public.aca_certificado_emitido FOR EACH ROW EXECUTE FUNCTION fn_generar_numero_certificado();


CREATE TRIGGER trg_aca_colegio_mod BEFORE UPDATE ON public.aca_colegio FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_aca_gestion_mod BEFORE UPDATE ON public.aca_gestion FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_aca_periodo_mod BEFORE UPDATE ON public.aca_periodo FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_aca_programa_mod BEFORE UPDATE ON public.aca_programa FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_aca_programa_aprobado_mod BEFORE UPDATE ON public.aca_programa_aprobado FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_aca_tipo_estudiante_mod BEFORE UPDATE ON public.aca_tipo_estudiante FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_eje_calificacion_mod BEFORE UPDATE ON public.eje_calificacion FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_log_calificacion AFTER INSERT OR UPDATE ON public.eje_calificacion FOR EACH ROW EXECUTE FUNCTION fn_log_cambio_calificacion();


CREATE TRIGGER trg_validar_progresion BEFORE INSERT OR UPDATE ON public.eje_calificacion FOR EACH ROW WHEN ((new.nota IS NOT NULL)) EXECUTE FUNCTION fn_validar_progresion_estudiante();


CREATE TRIGGER trg_eje_cronograma_modulo_mod BEFORE UPDATE ON public.eje_cronograma_modulo FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_validar_fechas_inscripcion BEFORE INSERT OR UPDATE ON public.eje_cronograma_modulo FOR EACH ROW EXECUTE FUNCTION fn_validar_fechas_inscripcion();


CREATE TRIGGER trg_validar_periodo_cronograma BEFORE INSERT OR UPDATE ON public.eje_cronograma_modulo FOR EACH ROW WHEN ((new.id_aca_periodo IS NOT NULL)) EXECUTE FUNCTION fn_validar_periodo_activo();


CREATE TRIGGER trg_calcular_nota_competencias AFTER INSERT OR UPDATE ON public.eje_detalle_calificacion FOR EACH ROW WHEN (((new.estado_detalle_calificacion)::text = 'ACTIVO'::text)) EXECUTE FUNCTION fn_calcular_nota_final_competencias();


CREATE TRIGGER trg_eje_docente_mod BEFORE UPDATE ON public.eje_docente FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_fin_arancel_mod BEFORE UPDATE ON public.fin_arancel FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_fin_convenio_mod BEFORE UPDATE ON public.fin_convenio FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_actualizar_saldo AFTER INSERT OR UPDATE ON public.fin_detalle_pago FOR EACH ROW WHEN (((new.estado_detalle_pago)::text <> 'ELIMINADO'::text)) EXECUTE FUNCTION fn_actualizar_saldo_pendiente();


CREATE TRIGGER trg_actualizar_saldo_obligacion AFTER INSERT OR DELETE OR UPDATE ON public.fin_detalle_pago FOR EACH ROW EXECUTE FUNCTION fn_actualizar_saldo_obligacion();


CREATE TRIGGER trg_fin_obligacion_pago_mod BEFORE UPDATE ON public.fin_obligacion_pago FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER tr_actualizar_estado_grupo AFTER UPDATE ON public.ins_grupo FOR EACH ROW EXECUTE FUNCTION fn_trigger_actualizar_estado_grupo();


CREATE TRIGGER tr_crear_cronogramas_grupo AFTER INSERT ON public.ins_grupo FOR EACH ROW EXECUTE FUNCTION fn_trigger_crear_cronogramas_grupo();


CREATE TRIGGER trg_actualizar_estado_grupo BEFORE INSERT OR UPDATE ON public.ins_grupo FOR EACH ROW WHEN (((new.fecha_inicio IS NOT NULL) AND (new.fecha_fin IS NOT NULL))) EXECUTE FUNCTION fn_actualizar_estado_grupo();


CREATE TRIGGER trg_ins_grupo_mod BEFORE UPDATE ON public.ins_grupo FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER tr_matricula_actualiza_grupo AFTER INSERT OR DELETE OR UPDATE ON public.ins_matricula FOR EACH ROW EXECUTE FUNCTION fn_trigger_matricula_actualiza_grupo();


CREATE TRIGGER trg_ins_matricula_mod BEFORE UPDATE ON public.ins_matricula FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trg_matricula_regular AFTER INSERT ON public.ins_matricula FOR EACH ROW EXECUTE FUNCTION fn_trigger_matricula_regular();


CREATE TRIGGER trg_validar_arancel_matricula BEFORE INSERT OR UPDATE ON public.ins_matricula FOR EACH ROW WHEN ((new.id_fin_arancel_aplicado IS NOT NULL)) EXECUTE FUNCTION fn_validar_arancel_vigente();


CREATE TRIGGER trg_validar_convenio_matricula BEFORE INSERT OR UPDATE ON public.ins_matricula FOR EACH ROW WHEN ((new.id_fin_convenio_aplicado IS NOT NULL)) EXECUTE FUNCTION fn_validar_convenio_vigente();


CREATE TRIGGER trg_prs_persona_mod BEFORE UPDATE ON public.prs_persona FOR EACH ROW EXECUTE FUNCTION fn_actualizar_auditoria_mod();


CREATE TRIGGER trigger_generar_resumen BEFORE INSERT OR UPDATE OF contenido ON public.pub_noticia FOR EACH ROW EXECUTE FUNCTION trigger_generar_resumen();