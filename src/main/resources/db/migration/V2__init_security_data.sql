-- V2__init_security_data.sql
-- Script de inicialización de datos de seguridad para el instituto técnico
-- Usuario sistema tiene acceso completo, contraseñas = nombres de usuario

-- ======================================
-- 1. INSERTAR ROLES BÁSICOS
-- ======================================
INSERT INTO seg_rol (nombre_rol, descripcion, estado_rol, fecha_reg, user_reg)
VALUES ('DESARROLLO', 'Equipo de desarrollo del sistema - Acceso completo', 'ACTIVO', CURRENT_TIMESTAMP, 1),
       ('PUBLIC', 'Acceso público sin autenticación', 'ACTIVO', CURRENT_TIMESTAMP, 1),
       ('ADMINISTRATIVO', 'Personal administrativo del instituto técnico', 'ACTIVO', CURRENT_TIMESTAMP, 1),
       ('DOCENTE', 'Profesores y docentes del instituto', 'ACTIVO', CURRENT_TIMESTAMP, 1),
       ('MATRICULADO', 'Estudiantes matriculados en programas', 'ACTIVO', CURRENT_TIMESTAMP, 1);

-- ======================================
-- 2. INSERTAR TAREAS POR ROL
-- ======================================

-- Tareas para DESARROLLO (acceso completo al sistema)
INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_SISTEMA', 'Control total del sistema', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_USUARIOS', 'Crear, modificar y eliminar usuarios', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_PROGRAMAS', 'Administrar programas académicos', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_PAGOS', 'Administrar pagos y obligaciones financieras', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_MATRICULAS', 'Administrar matrículas de estudiantes', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_CRONOGRAMA', 'Administrar cronogramas de módulos', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_CONFIGURACION', 'Modificar configuraciones del sistema', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'EMITIR_CERTIFICADOS', 'Generar y emitir certificados', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'CALIFICAR_ESTUDIANTES', 'Ingresar y modificar calificaciones', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'REVISAR_MONOGRAFIAS', 'Revisar y evaluar trabajos de grado', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_LOGS', 'Consultar logs del sistema', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_REPORTES', 'Acceso a todos los reportes', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DESARROLLO';

-- Tareas para PUBLIC
INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'CONSULTAR_INFO_PUBLICA', 'Consultar información pública del instituto', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'PUBLIC';

-- Tareas para ADMINISTRATIVO
INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_USUARIOS', 'Crear, modificar y eliminar usuarios', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'ADMINISTRATIVO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_PROGRAMAS', 'Administrar programas académicos', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'ADMINISTRATIVO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'EMITIR_CERTIFICADOS', 'Generar y emitir certificados', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'ADMINISTRATIVO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_PAGOS', 'Administrar pagos y obligaciones financieras', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'ADMINISTRATIVO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_MATRICULAS', 'Administrar matrículas de estudiantes', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'ADMINISTRATIVO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_REPORTES', 'Consultar reportes administrativos', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'ADMINISTRATIVO';

-- Tareas para DOCENTE
INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'CALIFICAR_ESTUDIANTES', 'Ingresar y modificar calificaciones', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DOCENTE';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'ADMINISTRAR_CRONOGRAMA', 'Administrar cronogramas de módulos asignados', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DOCENTE';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'REVISAR_MONOGRAFIAS', 'Revisar y evaluar trabajos de grado', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DOCENTE';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_ESTUDIANTES', 'Consultar información de estudiantes asignados', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DOCENTE';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_REPORTES_ACADEMICOS', 'Consultar reportes académicos', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'DOCENTE';

-- Tareas para MATRICULADO
INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_CALIFICACIONES', 'Consultar calificaciones propias', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'MATRICULADO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_CRONOGRAMA', 'Consultar cronogramas de módulos', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'MATRICULADO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'PRESENTAR_MONOGRAFIA', 'Presentar trabajos de grado', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'MATRICULADO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_PERFIL', 'Consultar y actualizar información personal', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'MATRICULADO';

INSERT INTO seg_tarea (id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
SELECT r.id_seg_rol, 'VER_PAGOS', 'Consultar estado de pagos y obligaciones', 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r WHERE r.nombre_rol = 'MATRICULADO';

-- ======================================
-- 3. INSERTAR USUARIOS INICIALES
-- ======================================

-- Usuario sistema/desarrollo (ID = 1) - Contraseña: sistema
INSERT INTO seg_usuario (id_seg_usuario, nombre_usuario, contrasena_hash, estado_usuario, fecha_reg, user_reg)
VALUES (1, 'sistema', '{bcrypt}$2a$10$Xl0yhvzLIaUIkzjHe/WuHeybPtuW/mhurTjz2FL/3J1dY8iCwVGAS', 'ACTIVO', CURRENT_TIMESTAMP, 1)
ON CONFLICT (id_seg_usuario) DO NOTHING;

-- Resetear la secuencia para que continúe desde 2
SELECT setval('seg_usuario_id_seg_usuario_seq', 1, true);

-- Usuario público - Contraseña: public
INSERT INTO seg_usuario (nombre_usuario, contrasena_hash, estado_usuario, fecha_reg, user_reg)
VALUES ('public', '{bcrypt}$2a$10$NKIlG/rdT8vvMKsEO3.wteT1dY8LzySGy0T5dL.Yz9N5dLgzJDhq6', 'ACTIVO', CURRENT_TIMESTAMP, 1);

-- Usuario administrativo - Contraseña: admin
INSERT INTO seg_usuario (nombre_usuario, contrasena_hash, estado_usuario, fecha_reg, user_reg)
VALUES ('admin', '{bcrypt}$2a$10$NKIlG/rdT8vvMKsEO3.wteT1dY8LzySGy0T5dL.Yz9N5dLgzJDhq6', 'ACTIVO', CURRENT_TIMESTAMP, 1);

-- Usuario docente - Contraseña: docente
INSERT INTO seg_usuario (nombre_usuario, contrasena_hash, estado_usuario, fecha_reg, user_reg)
VALUES ('docente', '{bcrypt}$2a$10$y/5VPsOSwJPt/dIYcUcl9eBlH.w4v4IJVV41TtZfRaV3P6j9SIH9q', 'ACTIVO', CURRENT_TIMESTAMP, 1);

-- Usuario estudiante - Contraseña: estudiante
INSERT INTO seg_usuario (nombre_usuario, contrasena_hash, estado_usuario, fecha_reg, user_reg)
VALUES ('estudiante', '{bcrypt}$2a$10$x8Q4T8E8XKWOxOdITi.k2O/Yl1qPF8RvmPQrP8nMpfJzLRsRJwsqa', 'ACTIVO', CURRENT_TIMESTAMP, 1);

-- ======================================
-- 4. ASIGNAR ROLES A USUARIOS
-- ======================================

-- Usuario sistema con rol DESARROLLO (ID=1) - ACCESO COMPLETO
INSERT INTO seg_ocupa (id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
SELECT r.id_seg_rol, u.id_seg_usuario, 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r, seg_usuario u
WHERE r.nombre_rol = 'DESARROLLO' AND u.nombre_usuario = 'sistema';

-- Usuario público con rol PUBLIC
INSERT INTO seg_ocupa (id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
SELECT r.id_seg_rol, u.id_seg_usuario, 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r, seg_usuario u
WHERE r.nombre_rol = 'PUBLIC' AND u.nombre_usuario = 'public';

-- Usuario admin con rol ADMINISTRATIVO
INSERT INTO seg_ocupa (id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
SELECT r.id_seg_rol, u.id_seg_usuario, 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r, seg_usuario u
WHERE r.nombre_rol = 'ADMINISTRATIVO' AND u.nombre_usuario = 'admin';

-- Usuario docente con rol DOCENTE
INSERT INTO seg_ocupa (id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
SELECT r.id_seg_rol, u.id_seg_usuario, 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r, seg_usuario u
WHERE r.nombre_rol = 'DOCENTE' AND u.nombre_usuario = 'docente';

-- Usuario estudiante con rol MATRICULADO
INSERT INTO seg_ocupa (id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
SELECT r.id_seg_rol, u.id_seg_usuario, 'ACTIVO', CURRENT_TIMESTAMP, 1
FROM seg_rol r, seg_usuario u
WHERE r.nombre_rol = 'MATRICULADO' AND u.nombre_usuario = 'estudiante';

-- ======================================
-- 5. VERIFICACIÓN DE DATOS CREADOS
-- ======================================

-- Los siguientes usuarios han sido creados:
-- 1. sistema / sistema (ID=1) - ROL: DESARROLLO - 12 TAREAS (ACCESO COMPLETO)
-- 2. public / public (ID=2) - ROL: PUBLIC - 1 TAREA
-- 3. admin / admin (ID=3) - ROL: ADMINISTRATIVO - 6 TAREAS
-- 4. docente / docente (ID=4) - ROL: DOCENTE - 5 TAREAS
-- 5. estudiante / estudiante (ID=5) - ROL: MATRICULADO - 5 TAREAS

-- RESUMEN DE TAREAS POR ROL:
-- DESARROLLO: 12 tareas (acceso total)
-- ADMINISTRATIVO: 6 tareas (administración general)
-- DOCENTE: 5 tareas (gestión académica)
-- MATRICULADO: 5 tareas (consultas estudiante)
-- PUBLIC: 1 tarea (información pública)