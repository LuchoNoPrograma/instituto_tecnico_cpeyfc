-- Inserción de datos ficticios para el sistema CPEYFC
-- 60 bolivianos del occidente + 40 bolivianos del oriente + 10 brasileños = 110 personas

INSERT INTO prs_persona (nombre, ap_paterno, ap_materno, ci, nro_celular, correo, fecha_nacimiento, estado_persona, fecha_reg, user_reg) VALUES

-- BOLIVIANOS DEL OCCIDENTE (60 personas) - Apellidos del altiplano y valles
('CARLOS', 'MAMANI', 'QUISPE', '8542367', '78934567', 'carlos.mamani@gmail.com', '1995-03-15', 'ACTIVO', NOW(), 1),
('MARIA', 'CONDORI', 'CHOQUE', '7823456', '75634891', 'maria.condori@hotmail.com', '1992-07-22', 'ACTIVO', NOW(), 1),
('JUAN', 'APAZA', 'FLORES', '9234567', '71234567', 'juan.apaza@gmail.com', '1988-11-10', 'ACTIVO', NOW(), 1),
('ANA', 'TICONA', 'HUANCA', '8976543', '78456123', 'ana.ticona@yahoo.com', '1990-05-30', 'ACTIVO', NOW(), 1),
('LUIS', 'CHOQUE', 'MAMANI', '7654321', '75987654', 'luis.choque@gmail.com', '1993-09-18', 'ACTIVO', NOW(), 1),
('ROSA', 'FLORES', 'QUISPE', '8345678', '78321654', 'rosa.flores@hotmail.com', '1987-01-25', 'ACTIVO', NOW(), 1),
('PEDRO', 'HUANCA', 'CONDORI', '9876543', '71876543', 'pedro.huanca@gmail.com', '1991-12-08', 'ACTIVO', NOW(), 1),
('CARMEN', 'QUISPE', 'APAZA', '7543210', '78654321', 'carmen.quispe@yahoo.com', '1989-04-14', 'ACTIVO', NOW(), 1),
('JOSE', 'CHURA', 'MAMANI', '8654329', '75432198', 'jose.chura@gmail.com', '1994-08-03', 'ACTIVO', NOW(), 1),
('SILVIA', 'CALCINA', 'TICONA', '6789123', '78987123', 'silvia.calcina@hotmail.com', '1996-02-17', 'ACTIVO', NOW(), 1),
('ROBERTO', 'POMA', 'CHOQUE', '8432167', '71345678', 'roberto.poma@gmail.com', '1985-10-12', 'ACTIVO', NOW(), 1),
('ELENA', 'LIMACHI', 'FLORES', '7891234', '78765432', 'elena.limachi@yahoo.com', '1992-06-28', 'ACTIVO', NOW(), 1),
('MIGUEL', 'CATACORA', 'HUANCA', '9123456', '75891234', 'miguel.catacora@gmail.com', '1990-03-05', 'ACTIVO', NOW(), 1),
('LAURA', 'NINA', 'QUISPE', '8567891', '78234567', 'laura.nina@hotmail.com', '1988-09-21', 'ACTIVO', NOW(), 1),
('DAVID', 'COLQUE', 'CONDORI', '7234567', '71567890', 'david.colque@gmail.com', '1993-11-16', 'ACTIVO', NOW(), 1),
('PATRICIA', 'CHAMBI', 'CHOQUE', '8890123', '78901234', 'patricia.chambi@yahoo.com', '1991-07-09', 'ACTIVO', NOW(), 1),
('FERNANDO', 'CHUQUIMIA', 'APAZA', '6456789', '75678901', 'fernando.chuquimia@gmail.com', '1987-01-13', 'ACTIVO', NOW(), 1),
('MONICA', 'SUXO', 'MAMANI', '8123456', '78345678', 'monica.suxo@hotmail.com', '1994-05-26', 'ACTIVO', NOW(), 1),
('ANDRES', 'MAMANI', 'TICONA', '7789012', '71890123', 'andres.mamani@gmail.com', '1989-12-02', 'ACTIVO', NOW(), 1),
('GABRIELA', 'QUISPE', 'FLORES', '9345678', '78567890', 'gabriela.quispe@yahoo.com', '1992-08-15', 'ACTIVO', NOW(), 1),
('OSCAR', 'CONDORI', 'HUANCA', '8012345', '75234567', 'oscar.condori@gmail.com', '1986-04-11', 'ACTIVO', NOW(), 1),
('VERONICA', 'CHOQUE', 'CHURA', '7678901', '78012345', 'veronica.choque@hotmail.com', '1995-10-07', 'ACTIVO', NOW(), 1),
('RICARDO', 'APAZA', 'CALCINA', '8456789', '71456789', 'ricardo.apaza@gmail.com', '1990-02-23', 'ACTIVO', NOW(), 1),
('ISABEL', 'FLORES', 'POMA', '6234567', '78678901', 'isabel.flores@yahoo.com', '1988-06-18', 'ACTIVO', NOW(), 1),
('JULIO', 'TICONA', 'LIMACHI', '8901234', '75890123', 'julio.ticona@gmail.com', '1993-09-04', 'ACTIVO', NOW(), 1),
('CLAUDIA', 'HUANCA', 'CATACORA', '7567890', '78123456', 'claudia.huanca@hotmail.com', '1991-11-29', 'ACTIVO', NOW(), 1),
('HECTOR', 'MAMANI', 'NINA', '8234567', '71789012', 'hector.mamani@gmail.com', '1987-03-14', 'ACTIVO', NOW(), 1),
('DIANA', 'QUISPE', 'COLQUE', '6890123', '78456789', 'diana.quispe@yahoo.com', '1994-07-20', 'ACTIVO', NOW(), 1),
('RAUL', 'CONDORI', 'CHAMBI', '8678901', '75567890', 'raul.condori@gmail.com', '1989-01-08', 'ACTIVO', NOW(), 1),
('ANDREA', 'CHOQUE', 'CHUQUIMIA', '7345678', '78890123', 'andrea.choque@hotmail.com', '1992-05-16', 'ACTIVO', NOW(), 1),
('MANUEL', 'APAZA', 'SUXO', '9012345', '71234890', 'manuel.apaza@gmail.com', '1990-09-12', 'ACTIVO', NOW(), 1),
('SANDRA', 'FLORES', 'MAMANI', '8789012', '78345679', 'sandra.flores@yahoo.com', '1988-12-25', 'ACTIVO', NOW(), 1),
('GERMAN', 'TICONA', 'QUISPE', '6567890', '75678902', 'german.ticona@gmail.com', '1995-04-06', 'ACTIVO', NOW(), 1),
('LUCIA', 'HUANCA', 'CONDORI', '8345679', '78901235', 'lucia.huanca@hotmail.com', '1991-08-19', 'ACTIVO', NOW(), 1),
('ALBERTO', 'CHURA', 'CHOQUE', '7123456', '71567891', 'alberto.chura@gmail.com', '1987-02-03', 'ACTIVO', NOW(), 1),
('PAOLA', 'CALCINA', 'APAZA', '8901235', '78234568', 'paola.calcina@yahoo.com', '1993-06-11', 'ACTIVO', NOW(), 1),
('GUSTAVO', 'POMA', 'FLORES', '6789124', '75890124', 'gustavo.poma@gmail.com', '1989-10-28', 'ACTIVO', NOW(), 1),
('MARTHA', 'LIMACHI', 'TICONA', '8456790', '78567891', 'martha.limachi@hotmail.com', '1992-01-14', 'ACTIVO', NOW(), 1),
('RODRIGO', 'CATACORA', 'HUANCA', '7234568', '71890124', 'rodrigo.catacora@gmail.com', '1990-11-30', 'ACTIVO', NOW(), 1),
('BEATRIZ', 'NINA', 'MAMANI', '8012346', '78123457', 'beatriz.nina@yahoo.com', '1987-05-17', 'ACTIVO', NOW(), 1),
('FRANCISCO', 'COLQUE', 'QUISPE', '6678901', '75456789', 'francisco.colque@gmail.com', '1994-09-22', 'ACTIVO', NOW(), 1),
('GLORIA', 'CHAMBI', 'CONDORI', '8345680', '78789012', 'gloria.chambi@hotmail.com', '1991-03-08', 'ACTIVO', NOW(), 1),
('SERGIO', 'CHUQUIMIA', 'CHOQUE', '7890123', '71234891', 'sergio.chuquimia@gmail.com', '1988-07-25', 'ACTIVO', NOW(), 1),
('ELIZABETH', 'SUXO', 'APAZA', '9567890', '78456790', 'elizabeth.suxo@yahoo.com', '1995-01-11', 'ACTIVO', NOW(), 1),
('WALTER', 'MAMANI', 'FLORES', '8234568', '75789013', 'walter.mamani@gmail.com', '1989-12-04', 'ACTIVO', NOW(), 1),
('NANCY', 'QUISPE', 'TICONA', '6901234', '78012346', 'nancy.quispe@hotmail.com', '1992-08-29', 'ACTIVO', NOW(), 1),
('VICTOR', 'CONDORI', 'HUANCA', '8567892', '71567892', 'victor.condori@gmail.com', '1990-04-15', 'ACTIVO', NOW(), 1),
('ROSARIO', 'CHOQUE', 'CHURA', '7345679', '78890124', 'rosario.choque@yahoo.com', '1987-10-19', 'ACTIVO', NOW(), 1),
('ALFREDO', 'APAZA', 'CALCINA', '8678902', '75234568', 'alfredo.apaza@gmail.com', '1993-02-26', 'ACTIVO', NOW(), 1),
('JUANA', 'FLORES', 'POMA', '6456790', '78567892', 'juana.flores@hotmail.com', '1991-06-13', 'ACTIVO', NOW(), 1),
('MARIO', 'TICONA', 'LIMACHI', '8123457', '71890125', 'mario.ticona@gmail.com', '1988-11-07', 'ACTIVO', NOW(), 1),
('TEODORA', 'HUANCA', 'CATACORA', '7789013', '78345680', 'teodora.huanca@yahoo.com', '1994-03-23', 'ACTIVO', NOW(), 1),
('ROLANDO', 'MAMANI', 'NINA', '9012346', '75678903', 'rolando.mamani@gmail.com', '1989-07-18', 'ACTIVO', NOW(), 1),
('ESPERANZA', 'QUISPE', 'COLQUE', '8456791', '78901236', 'esperanza.quispe@hotmail.com', '1992-11-12', 'ACTIVO', NOW(), 1),
('GONZALO', 'CONDORI', 'CHAMBI', '6234568', '71456790', 'gonzalo.condori@gmail.com', '1990-01-28', 'ACTIVO', NOW(), 1),
('DELIA', 'CHOQUE', 'CHUQUIMIA', '8901236', '78678902', 'delia.choque@yahoo.com', '1987-05-14', 'ACTIVO', NOW(), 1),
('MARCELO', 'APAZA', 'SUXO', '7567891', '75890125', 'marcelo.apaza@gmail.com', '1995-09-01', 'ACTIVO', NOW(), 1),
('FELICIA', 'FLORES', 'MAMANI', '8234569', '78123458', 'felicia.flores@hotmail.com', '1991-12-17', 'ACTIVO', NOW(), 1),
('RENE', 'TICONA', 'QUISPE', '6890124', '71789013', 'rene.ticona@gmail.com', '1988-04-06', 'ACTIVO', NOW(), 1),
('LIDIA', 'HUANCA', 'CONDORI', '8678903', '78456791', 'lidia.huanca@yahoo.com', '1993-08-21', 'ACTIVO', NOW(), 1),

-- BOLIVIANOS DEL ORIENTE (40 personas) - Apellidos orientales
('FERNANDO', 'JUSTINIANO', 'ROCA', '4123456', '78234569', 'fernando.justiniano@gmail.com', '1990-03-12', 'ACTIVO', NOW(), 1),
('CARLA', 'SALVATIERRA', 'ANTELO', '4567890', '71456791', 'carla.salvatierra@hotmail.com', '1992-07-18', 'ACTIVO', NOW(), 1),
('DIEGO', 'PEÑA', 'SUAREZ', '4789123', '78567893', 'diego.pena@gmail.com', '1988-11-25', 'ACTIVO', NOW(), 1),
('PAOLA', 'CRONENBOLD', 'MELGAR', '4234567', '75890126', 'paola.cronenbold@yahoo.com', '1994-02-09', 'ACTIVO', NOW(), 1),
('CARLOS', 'RIBERA', 'COSTAS', '4456789', '78123459', 'carlos.ribera@gmail.com', '1989-06-14', 'ACTIVO', NOW(), 1),
('MARIA', 'TERCEROS', 'BARBERY', '4678901', '71789014', 'maria.terceros@hotmail.com', '1991-10-03', 'ACTIVO', NOW(), 1),
('LUIS', 'MORALES', 'VELASCO', '4890123', '78456792', 'luis.morales@gmail.com', '1987-01-20', 'ACTIVO', NOW(), 1),
('ANA', 'GUZMAN', 'MONTERO', '4012345', '75234569', 'ana.guzman@yahoo.com', '1995-05-07', 'ACTIVO', NOW(), 1),
('JOSE', 'SANDOVAL', 'ROCHA', '4345678', '78678903', 'jose.sandoval@gmail.com', '1990-09-22', 'ACTIVO', NOW(), 1),
('SOFIA', 'ROCA', 'JUSTINIANO', '4567891', '71234892', 'sofia.roca@hotmail.com', '1992-12-15', 'ACTIVO', NOW(), 1),
('ROBERTO', 'ANTELO', 'SALVATIERRA', '4789124', '78901237', 'roberto.antelo@gmail.com', '1988-04-28', 'ACTIVO', NOW(), 1),
('CLAUDIA', 'SUAREZ', 'PEÑA', '4123457', '75567891', 'claudia.suarez@yahoo.com', '1993-08-11', 'ACTIVO', NOW(), 1),
('MIGUEL', 'MELGAR', 'CRONENBOLD', '4456790', '78345681', 'miguel.melgar@gmail.com', '1989-11-26', 'ACTIVO', NOW(), 1),
('VERONICA', 'COSTAS', 'RIBERA', '4678902', '71890126', 'veronica.costas@hotmail.com', '1991-03-13', 'ACTIVO', NOW(), 1),
('DAVID', 'BARBERY', 'TERCEROS', '4890124', '78567894', 'david.barbery@gmail.com', '1987-07-30', 'ACTIVO', NOW(), 1),
('PATRICIA', 'VELASCO', 'MORALES', '4234568', '75890127', 'patricia.velasco@yahoo.com', '1994-11-16', 'ACTIVO', NOW(), 1),
('ANDRES', 'MONTERO', 'GUZMAN', '4567892', '78123460', 'andres.montero@gmail.com', '1990-02-04', 'ACTIVO', NOW(), 1),
('MONICA', 'ROCHA', 'SANDOVAL', '4789125', '71456792', 'monica.rocha@hotmail.com', '1992-06-21', 'ACTIVO', NOW(), 1),
('OSCAR', 'JUSTINIANO', 'ROCA', '4012346', '78789013', 'oscar.justiniano@gmail.com', '1988-10-08', 'ACTIVO', NOW(), 1),
('GABRIELA', 'SALVATIERRA', 'ANTELO', '4345679', '75234570', 'gabriela.salvatierra@yahoo.com', '1995-01-25', 'ACTIVO', NOW(), 1),
('RICARDO', 'PEÑA', 'SUAREZ', '4678903', '78456793', 'ricardo.pena@gmail.com', '1989-05-12', 'ACTIVO', NOW(), 1),
('ISABEL', 'CRONENBOLD', 'MELGAR', '4890125', '71678902', 'isabel.cronenbold@hotmail.com', '1991-09-29', 'ACTIVO', NOW(), 1),
('JULIO', 'RIBERA', 'COSTAS', '4123458', '78012347', 'julio.ribera@gmail.com', '1987-12-16', 'ACTIVO', NOW(), 1),
('CARMEN', 'TERCEROS', 'BARBERY', '4456791', '75789014', 'carmen.terceros@yahoo.com', '1993-04-03', 'ACTIVO', NOW(), 1),
('HECTOR', 'MORALES', 'VELASCO', '4789126', '78345682', 'hector.morales@gmail.com', '1990-08-20', 'ACTIVO', NOW(), 1),
('DIANA', 'GUZMAN', 'MONTERO', '4234569', '71567893', 'diana.guzman@hotmail.com', '1992-11-06', 'ACTIVO', NOW(), 1),
('RAUL', 'SANDOVAL', 'ROCHA', '4567893', '78890125', 'raul.sandoval@gmail.com', '1988-03-24', 'ACTIVO', NOW(), 1),
('SANDRA', 'ROCA', 'JUSTINIANO', '4890126', '75456790', 'sandra.roca@yahoo.com', '1994-07-10', 'ACTIVO', NOW(), 1),
('MANUEL', 'ANTELO', 'SALVATIERRA', '4012347', '78678904', 'manuel.antelo@gmail.com', '1989-10-27', 'ACTIVO', NOW(), 1),
('LUCIA', 'SUAREZ', 'PEÑA', '4345680', '71234893', 'lucia.suarez@hotmail.com', '1991-02-13', 'ACTIVO', NOW(), 1),
('ALBERTO', 'MELGAR', 'CRONENBOLD', '4678904', '78567895', 'alberto.melgar@gmail.com', '1987-06-01', 'ACTIVO', NOW(), 1),
('PAOLA', 'COSTAS', 'RIBERA', '4890127', '75890128', 'paola.costas@yahoo.com', '1995-09-17', 'ACTIVO', NOW(), 1),
('GUSTAVO', 'BARBERY', 'TERCEROS', '4123459', '78123461', 'gustavo.barbery@gmail.com', '1990-12-04', 'ACTIVO', NOW(), 1),
('MARTHA', 'VELASCO', 'MORALES', '4456792', '71789015', 'martha.velasco@hotmail.com', '1992-04-21', 'ACTIVO', NOW(), 1),
('RODRIGO', 'MONTERO', 'GUZMAN', '4789127', '78456794', 'rodrigo.montero@gmail.com', '1988-08-08', 'ACTIVO', NOW(), 1),
('BEATRIZ', 'ROCHA', 'SANDOVAL', '4234570', '75567892', 'beatriz.rocha@yahoo.com', '1993-11-24', 'ACTIVO', NOW(), 1),
('FRANCISCO', 'JUSTINIANO', 'ROCA', '4567894', '78901238', 'francisco.justiniano@gmail.com', '1989-03-11', 'ACTIVO', NOW(), 1),
('GLORIA', 'SALVATIERRA', 'ANTELO', '4890128', '71456793', 'gloria.salvatierra@hotmail.com', '1991-07-28', 'ACTIVO', NOW(), 1),
('SERGIO', 'PEÑA', 'SUAREZ', '4012348', '78789014', 'sergio.pena@gmail.com', '1987-11-14', 'ACTIVO', NOW(), 1),
('ELIZABETH', 'CRONENBOLD', 'MELGAR', '4345681', '75234571', 'elizabeth.cronenbold@yahoo.com', '1994-02-01', 'ACTIVO', NOW(), 1),

-- BRASILEÑOS (10 personas)
('CARLOS', 'SILVA', 'SANTOS', '12345678', '78234570', 'carlos.silva@gmail.com', '1990-05-15', 'ACTIVO', NOW(), 1),
('MARIA', 'OLIVEIRA', 'COSTA', '23456789', '71456794', 'maria.oliveira@hotmail.com', '1992-09-22', 'ACTIVO', NOW(), 1),
('JOAO', 'FERREIRA', 'ALMEIDA', '34567890', '78567896', 'joao.ferreira@gmail.com', '1988-01-08', 'ACTIVO', NOW(), 1),
('ANA', 'RODRIGUES', 'LIMA', '45678901', '75890129', 'ana.rodrigues@yahoo.com', '1993-12-03', 'ACTIVO', NOW(), 1),
('PEDRO', 'MARTINS', 'PEREIRA', '56789012', '78123462', 'pedro.martins@gmail.com', '1989-04-17', 'ACTIVO', NOW(), 1),
('LUCIA', 'CARVALHO', 'BARBOSA', '67890123', '71789016', 'lucia.carvalho@hotmail.com', '1991-08-24', 'ACTIVO', NOW(), 1),
('MIGUEL', 'SOUZA', 'RIBEIRO', '78901234', '78456795', 'miguel.souza@gmail.com', '1987-10-11', 'ACTIVO', NOW(), 1),
('PATRICIA', 'GOMES', 'ARAUJO', '89012345', '75567893', 'patricia.gomes@yahoo.com', '1994-06-28', 'ACTIVO', NOW(), 1),
('RAFAEL', 'MOREIRA', 'CARDOSO', '90123456', '78890126', 'rafael.moreira@gmail.com', '1990-11-14', 'ACTIVO', NOW(), 1),
('CLAUDIA', 'NASCIMENTO', 'MACHADO', '01234567', '71234894', 'claudia.nascimento@hotmail.com', '1992-03-07', 'ACTIVO', NOW(), 1);


-- Tabla: aca_area
select * from aca_area
INSERT INTO aca_area (nombre_area, estado_area, fecha_reg, user_reg)
VALUES ('TECNOLOGIAS DE LA INFORMACION', 'ACTIVO', NOW(), 1),
       ('ELECTRONICA Y TELECOMUNICACIONES', 'ACTIVO', NOW(), 1),
       ('CONSTRUCCION CIVIL', 'ACTIVO', NOW(), 1),
       ('MECANICA AUTOMOTRIZ', 'ACTIVO', NOW(), 1),
       ('ELECTRICIDAD INDUSTRIAL', 'ACTIVO', NOW(), 1),
       ('SOLDADURA Y ESTRUCTURAS METALICAS', 'ACTIVO', NOW(), 1),
       ('GASTRONOMIA Y HOTELERIA', 'ACTIVO', NOW(), 1),
       ('DISEÑO GRAFICO Y PUBLICIDAD', 'ACTIVO', NOW(), 1),
       ('ADMINISTRACION DE EMPRESAS', 'ACTIVO', NOW(), 1),
       ('CONTABILIDAD Y FINANZAS', 'ACTIVO', NOW(), 1);

-- Tabla: aca_modalidad
INSERT INTO aca_modalidad (nombre_modalidad, estado_modalidad, fecha_reg, user_reg)
VALUES ('PRESENCIAL', 'ACTIVO', NOW(), 1),
       ('SEMIPRESENCIAL', 'ACTIVO', NOW(), 1),
       ('VIRTUAL', 'ACTIVO', NOW(), 1),
       ('A DISTANCIA', 'ACTIVO', NOW(), 1);

-- Tabla: aca_modulo
INSERT INTO aca_modulo (nombre_modulo, estado_modulo, fecha_reg, user_reg)
VALUES ('FUNDAMENTOS DE PROGRAMACION', 'ACTIVO', NOW(), 1),
       ('BASE DE DATOS', 'ACTIVO', NOW(), 1),
       ('DESARROLLO WEB', 'ACTIVO', NOW(), 1),
       ('REDES Y COMUNICACIONES', 'ACTIVO', NOW(), 1),
       ('SEGURIDAD INFORMATICA', 'ACTIVO', NOW(), 1),
       ('ELECTRONICA BASICA', 'ACTIVO', NOW(), 1),
       ('CIRCUITOS ELECTRONICOS', 'ACTIVO', NOW(), 1),
       ('TELECOMUNICACIONES', 'ACTIVO', NOW(), 1),
       ('MICROCONTROLADORES', 'ACTIVO', NOW(), 1),
       ('AUTOMATIZACION INDUSTRIAL', 'ACTIVO', NOW(), 1),
       ('MATERIALES DE CONSTRUCCION', 'ACTIVO', NOW(), 1),
       ('ESTRUCTURAS DE HORMIGON', 'ACTIVO', NOW(), 1),
       ('TOPOGRAFIA', 'ACTIVO', NOW(), 1),
       ('INSTALACIONES SANITARIAS', 'ACTIVO', NOW(), 1),
       ('SUPERVISION DE OBRAS', 'ACTIVO', NOW(), 1),
       ('MOTORES DE COMBUSTION', 'ACTIVO', NOW(), 1),
       ('SISTEMA ELECTRICO AUTOMOTRIZ', 'ACTIVO', NOW(), 1),
       ('TRANSMISION Y FRENOS', 'ACTIVO', NOW(), 1),
       ('DIAGNOSTICO AUTOMOTRIZ', 'ACTIVO', NOW(), 1),
       ('MANTENIMIENTO PREVENTIVO', 'ACTIVO', NOW(), 1),
       ('INSTALACIONES ELECTRICAS', 'ACTIVO', NOW(), 1),
       ('MOTORES ELECTRICOS', 'ACTIVO', NOW(), 1),
       ('CONTROL INDUSTRIAL', 'ACTIVO', NOW(), 1),
       ('INSTRUMENTACION', 'ACTIVO', NOW(), 1),
       ('ENERGIA RENOVABLE', 'ACTIVO', NOW(), 1),
       ('SOLDADURA AL ARCO', 'ACTIVO', NOW(), 1),
       ('SOLDADURA MIG-MAG', 'ACTIVO', NOW(), 1),
       ('SOLDADURA TIG', 'ACTIVO', NOW(), 1),
       ('ESTRUCTURAS METALICAS', 'ACTIVO', NOW(), 1),
       ('HERRERIA ARTISTICA', 'ACTIVO', NOW(), 1),
       ('COCINA NACIONAL', 'ACTIVO', NOW(), 1),
       ('COCINA INTERNACIONAL', 'ACTIVO', NOW(), 1),
       ('REPOSTERIA Y PANADERIA', 'ACTIVO', NOW(), 1),
       ('SERVICIO AL CLIENTE', 'ACTIVO', NOW(), 1),
       ('ADMINISTRACION HOTELERA', 'ACTIVO', NOW(), 1),
       ('DISEÑO DIGITAL', 'ACTIVO', NOW(), 1),
       ('FOTOGRAFIA', 'ACTIVO', NOW(), 1),
       ('ILUSTRACION', 'ACTIVO', NOW(), 1),
       ('MARKETING DIGITAL', 'ACTIVO', NOW(), 1),
       ('BRANDING', 'ACTIVO', NOW(), 1),
       ('GESTION EMPRESARIAL', 'ACTIVO', NOW(), 1),
       ('RECURSOS HUMANOS', 'ACTIVO', NOW(), 1),
       ('MARKETING Y VENTAS', 'ACTIVO', NOW(), 1),
       ('LOGISTICA', 'ACTIVO', NOW(), 1),
       ('EMPRENDIMIENTO', 'ACTIVO', NOW(), 1),
       ('CONTABILIDAD GENERAL', 'ACTIVO', NOW(), 1),
       ('CONTABILIDAD DE COSTOS', 'ACTIVO', NOW(), 1),
       ('AUDITORIA', 'ACTIVO', NOW(), 1),
       ('FINANZAS EMPRESARIALES', 'ACTIVO', NOW(), 1),
       ('TRIBUTACION', 'ACTIVO', NOW(), 1);

-- ===============================================
-- TABLAS PARA NOTO
-- ===============================================

-- Tabla: aca_nivel
INSERT INTO aca_nivel (nombre_nivel, estado_nivel, fecha_reg, user_reg)
VALUES ('NIVEL 1', 'ACTIVO', NOW(), 1),
       ('NIVEL 2', 'ACTIVO', NOW(), 1),
       ('NIVEL 3', 'ACTIVO', NOW(), 1),
       ('NIVEL 4', 'ACTIVO', NOW(), 1),
       ('NIVEL 5', 'ACTIVO', NOW(), 1),
       ('NIVEL 6', 'ACTIVO', NOW(), 1),
       ('NIVEL 7', 'ACTIVO', NOW(), 1),
       ('NIVEL 8', 'ACTIVO', NOW(), 1),
       ('NIVEL 9', 'ACTIVO', NOW(), 1),
       ('NIVEL 10', 'ACTIVO', NOW(), 1),
       ('NIVEL 11', 'ACTIVO', NOW(), 1),
       ('NIVEL 12', 'ACTIVO', NOW(), 1),
       ('NIVEL 13', 'ACTIVO', NOW(), 1),
       ('NIVEL 14', 'ACTIVO', NOW(), 1),
       ('NIVEL 15', 'ACTIVO', NOW(), 1),
       ('NIVEL 16', 'ACTIVO', NOW(), 1),
       ('NIVEL 17', 'ACTIVO', NOW(), 1),
       ('NIVEL 18', 'ACTIVO', NOW(), 1),
       ('NIVEL 19', 'ACTIVO', NOW(), 1),
       ('NIVEL 20', 'ACTIVO', NOW(), 1);

INSERT INTO fin_concepto_pago (nombre_concepto, descripcion, estado_concepto_pago, fecha_reg, user_reg)
VALUES ('MATRICULA SEMESTRAL', 'PAGO DE MATRICULA PARA INSCRIPCION AL PROGRAMA', 'ACTIVO', NOW(), 1),
       ('CURSO COMPLETO', 'PAGO TOTAL DEL CURSO ACADEMICO', 'ACTIVO', NOW(), 1),
       ('IMPRESION DE CERTIFICADO', 'COSTO DE IMPRESION Y EMISION DE CERTIFICADO', 'ACTIVO', NOW(), 1),
       ('DEFENSA DE MONOGRAFIA', 'PAGO POR PROCESO DE DEFENSA DE MONOGRAFIA', 'ACTIVO', NOW(), 1);

INSERT INTO aca_programa (id_aca_area, nombre_programa, sigla, estado_programa, fecha_reg, user_reg)
VALUES
-- PROGRAMAS DE TECNOLOGIAS DE LA INFORMACION (id_aca_area = 1)
(3, 'TECNICO SUPERIOR EN DESARROLLO DE SOFTWARE', 'TSDS', 'ACTIVO', NOW(), 1),
(3, 'TECNICO SUPERIOR EN REDES Y TELECOMUNICACIONES', 'TSRT', 'ACTIVO', NOW(), 1),
(3, 'TECNICO SUPERIOR EN SEGURIDAD INFORMATICA', 'TSSI', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE ELECTRONICA Y TELECOMUNICACIONES (id_aca_area = 2)
(4, 'TECNICO SUPERIOR EN ELECTRONICA INDUSTRIAL', 'TSEI', 'ACTIVO', NOW(), 1),
(4, 'TECNICO SUPERIOR EN TELECOMUNICACIONES', 'TSTE', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE CONSTRUCCION CIVIL (id_aca_area = 3)
(5, 'TECNICO SUPERIOR EN CONSTRUCCION CIVIL', 'TSCC', 'ACTIVO', NOW(), 1),
(5, 'TECNICO SUPERIOR EN TOPOGRAFIA', 'TSTO', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE MECANICA AUTOMOTRIZ (id_aca_area = 4)
(6, 'TECNICO SUPERIOR EN MECANICA AUTOMOTRIZ', 'TSMA', 'ACTIVO', NOW(), 1),
(6, 'TECNICO SUPERIOR EN DIAGNOSTICO AUTOMOTRIZ', 'TSDA', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE ELECTRICIDAD INDUSTRIAL (id_aca_area = 5)
(7, 'TECNICO SUPERIOR EN ELECTRICIDAD INDUSTRIAL', 'TSEI', 'ACTIVO', NOW(), 1),
(7, 'TECNICO SUPERIOR EN ENERGIA RENOVABLE', 'TSER', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE SOLDADURA Y ESTRUCTURAS METALICAS (id_aca_area = 6)
(8, 'TECNICO SUPERIOR EN SOLDADURA INDUSTRIAL', 'TSSI', 'ACTIVO', NOW(), 1),
(8, 'TECNICO SUPERIOR EN ESTRUCTURAS METALICAS', 'TSEM', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE GASTRONOMIA Y HOTELERIA (id_aca_area = 7)
(9, 'TECNICO SUPERIOR EN GASTRONOMIA', 'TSG', 'ACTIVO', NOW(), 1),
(9, 'TECNICO SUPERIOR EN HOTELERIA Y TURISMO', 'TSHT', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE DISEÑO GRAFICO Y PUBLICIDAD (id_aca_area = 8)
(10, 'TECNICO SUPERIOR EN DISEÑO GRAFICO', 'TSDG', 'ACTIVO', NOW(), 1),
(10, 'TECNICO SUPERIOR EN PUBLICIDAD Y MARKETING', 'TSPM', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE ADMINISTRACION DE EMPRESAS (id_aca_area = 9)
(11, 'TECNICO SUPERIOR EN ADMINISTRACION DE EMPRESAS', 'TSAE', 'ACTIVO', NOW(), 1),
(11, 'TECNICO SUPERIOR EN RECURSOS HUMANOS', 'TSRH', 'ACTIVO', NOW(), 1),

-- PROGRAMAS DE CONTABILIDAD Y FINANZAS (id_aca_area = 10)
(12, 'TECNICO SUPERIOR EN CONTABILIDAD', 'TSC', 'ACTIVO', NOW(), 1),
(12, 'TECNICO SUPERIOR EN FINANZAS', 'TSF', 'ACTIVO', NOW(), 1);

CREATE OR REPLACE FUNCTION obtener_personas_activas()
  RETURNS SETOF prs_persona AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM prs_persona
    WHERE estado_persona = 'ACTIVO';
END;
$$ LANGUAGE plpgsql;

select * from obtener_personas_activas();

SELECT
      ROW_NUMBER() OVER (ORDER BY nombre) AS orden,
      nombre, ap_paterno, ap_materno, ci
FROM prs_persona;