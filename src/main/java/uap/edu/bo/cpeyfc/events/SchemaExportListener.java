package uap.edu.bo.cpeyfc.events;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Component
@RequiredArgsConstructor
@Slf4j
public class SchemaExportListener {

  private final Environment env;

  @EventListener(ApplicationReadyEvent.class)
  public void exportarSchemaAlIniciar() {
    try {
      log.info("=== Iniciando exportación con pg_dump ===");

      Path directorioSalida = Paths.get("src/main/resources/db/schema");
      Files.createDirectories(directorioSalida);

      // Extraer credenciales del application.properties
      String jdbcUrl = env.getProperty("spring.datasource.url");
      assert jdbcUrl != null;
      String[] urlParts = jdbcUrl.split("//")[1].split("/");
      String hostPort = urlParts[0];
      String database = urlParts[1].split("\\?")[0];

      String host = hostPort.split(":")[0];
      String puerto = hostPort.split(":")[1];
      String usuario = env.getProperty("spring.datasource.username");
      String password = env.getProperty("spring.datasource.password");

      exportarTablas(directorioSalida, host, puerto, database, usuario, password);
      exportarFunciones(directorioSalida, host, puerto, database, usuario, password);
      exportarVistas(directorioSalida, host, puerto, database, usuario, password);
      exportarTriggers(directorioSalida, host, puerto, database, usuario, password);

      log.info("=== ✓ Exportación completada en: {} ===", directorioSalida.toAbsolutePath());

    } catch (Exception e) {
      log.error("Error al exportar schema", e);
    }
  }

  private void exportarTablas(Path directorio, String host, String puerto, String database, String usuario, String password) throws IOException, InterruptedException {
    log.info("Exportando tablas...");

    ProcessBuilder pb = new ProcessBuilder(
      "psql",
      "-h", host,
      "-p", puerto,
      "-U", usuario,
      "-d", database,
      "-t",
      "-A",
      "-c", """
      -- Obtener CREATE TABLE
      SELECT
        'CREATE TABLE ' || c.relname || ' (' || E'\\n' ||
        string_agg(
          '  ' || a.attname || ' ' ||
          pg_catalog.format_type(a.atttypid, a.atttypmod) ||
          CASE WHEN a.attnotnull THEN ' NOT NULL' ELSE '' END ||
          CASE WHEN ad.adbin IS NOT NULL
            THEN ' DEFAULT ' || pg_catalog.pg_get_expr(ad.adbin, ad.adrelid)
            ELSE ''
          END,
          ',' || E'\\n'
          ORDER BY a.attnum
        ) || E'\\n' || ');' || E'\\n\\n'
      FROM pg_catalog.pg_class c
      JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid
      LEFT JOIN pg_catalog.pg_attrdef ad ON ad.adrelid = c.oid AND ad.adnum = a.attnum
      WHERE n.nspname = 'public'
        AND c.relkind = 'r'
        AND c.relname NOT LIKE 'pg_%'
        AND c.relname NOT LIKE 'sql_%'
        AND c.relname != 'flyway_schema_history'
        AND a.attnum > 0
        AND NOT a.attisdropped
      GROUP BY c.relname, c.oid
      ORDER BY c.relname;
      
      -- Primary Keys
      SELECT
        E'\\n-- Primary Keys\\n' ||
        'ALTER TABLE ' || tc.table_name ||
        ' ADD CONSTRAINT ' || tc.constraint_name ||
        ' PRIMARY KEY (' ||
        string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) ||
        ');' || E'\\n'
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      WHERE tc.constraint_type = 'PRIMARY KEY'
        AND tc.table_schema = 'public'
        AND tc.table_name NOT LIKE 'pg_%'
        AND tc.table_name NOT LIKE 'sql_%'
        AND tc.table_name != 'flyway_schema_history'
      GROUP BY tc.table_name, tc.constraint_name
      ORDER BY tc.table_name
      LIMIT 1;
      
      SELECT
        'ALTER TABLE ' || tc.table_name ||
        ' ADD CONSTRAINT ' || tc.constraint_name ||
        ' PRIMARY KEY (' ||
        string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) ||
        ');' || E'\\n'
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      WHERE tc.constraint_type = 'PRIMARY KEY'
        AND tc.table_schema = 'public'
        AND tc.table_name NOT LIKE 'pg_%'
        AND tc.table_name NOT LIKE 'sql_%'
        AND tc.table_name != 'flyway_schema_history'
      GROUP BY tc.table_name, tc.constraint_name
      ORDER BY tc.table_name
      OFFSET 1;
      
      -- Foreign Keys
      SELECT
        E'\\n-- Foreign Keys\\n' ||
        'ALTER TABLE ' || tc.table_name ||
        ' ADD CONSTRAINT ' || tc.constraint_name ||
        ' FOREIGN KEY (' ||
        string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) ||
        ') REFERENCES ' || ccu.table_name ||
        ' (' ||
        (SELECT string_agg(kcu2.column_name, ', ' ORDER BY kcu2.ordinal_position)
         FROM information_schema.key_column_usage kcu2
         WHERE kcu2.constraint_name = (
           SELECT unique_constraint_name 
           FROM information_schema.referential_constraints 
           WHERE constraint_name = tc.constraint_name
         )) ||
        ')' ||
        CASE WHEN rc.update_rule != 'NO ACTION' THEN ' ON UPDATE ' || rc.update_rule ELSE '' END ||
        CASE WHEN rc.delete_rule != 'NO ACTION' THEN ' ON DELETE ' || rc.delete_rule ELSE '' END ||
        ';' || E'\\n'
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
      JOIN information_schema.referential_constraints rc
        ON rc.constraint_name = tc.constraint_name
        AND rc.constraint_schema = tc.table_schema
      WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public'
        AND tc.table_name NOT LIKE 'pg_%'
        AND tc.table_name NOT LIKE 'sql_%'
        AND tc.table_name != 'flyway_schema_history'
      GROUP BY tc.table_name, tc.constraint_name, ccu.table_name, rc.update_rule, rc.delete_rule
      ORDER BY tc.table_name
      LIMIT 1;
      
      SELECT
        'ALTER TABLE ' || tc.table_name ||
        ' ADD CONSTRAINT ' || tc.constraint_name ||
        ' FOREIGN KEY (' ||
        string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) ||
        ') REFERENCES ' || ccu.table_name ||
        ' (' ||
        (SELECT string_agg(kcu2.column_name, ', ' ORDER BY kcu2.ordinal_position)
         FROM information_schema.key_column_usage kcu2
         WHERE kcu2.constraint_name = (
           SELECT unique_constraint_name 
           FROM information_schema.referential_constraints 
           WHERE constraint_name = tc.constraint_name
         )) ||
        ')' ||
        CASE WHEN rc.update_rule != 'NO ACTION' THEN ' ON UPDATE ' || rc.update_rule ELSE '' END ||
        CASE WHEN rc.delete_rule != 'NO ACTION' THEN ' ON DELETE ' || rc.delete_rule ELSE '' END ||
        ';' || E'\\n'
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
      JOIN information_schema.referential_constraints rc
        ON rc.constraint_name = tc.constraint_name
        AND rc.constraint_schema = tc.table_schema
      WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public'
        AND tc.table_name NOT LIKE 'pg_%'
        AND tc.table_name NOT LIKE 'sql_%'
        AND tc.table_name != 'flyway_schema_history'
      GROUP BY tc.table_name, tc.constraint_name, ccu.table_name, rc.update_rule, rc.delete_rule
      ORDER BY tc.table_name
      OFFSET 1;
    """
    );

    pb.environment().put("PGPASSWORD", password);

    String resultado = ejecutarComando(pb);

    Files.writeString(directorio.resolve("tablas.sql"),
      "-- ============================================\n" +
      "-- TABLAS DEL SCHEMA PUBLIC\n" +
      "-- ============================================\n\n" +
      resultado.trim());

    log.info("✓ Tablas exportadas");
  }

  private void exportarFunciones(Path directorio, String host, String puerto, String database, String usuario, String password) throws IOException, InterruptedException {
    log.info("Exportando funciones...");

    // Para funciones usamos psql con query directa
    ProcessBuilder pb = new ProcessBuilder(
      "psql",
      "-h", host,
      "-p", puerto,
      "-U", usuario,
      "-d", database,
      "-t",  // Sin headers
      "-A",  // Sin formato
      "-c", """
        SELECT pg_get_functiondef(p.oid) || E';\\n\\n'
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.prokind = 'f'
        ORDER BY p.proname
      """
    );

    pb.environment().put("PGPASSWORD", password);

    String resultado = ejecutarComando(pb);

    Files.writeString(directorio.resolve("funciones.sql"),
      "-- ============================================\n" +
      "-- FUNCIONES ALMACENADAS\n" +
      "-- ============================================\n\n" +
      resultado.trim());

    log.info("✓ Funciones exportadas");
  }

  private void exportarVistas(Path directorio, String host, String puerto, String database, String usuario, String password) throws IOException, InterruptedException {
    log.info("Exportando vistas...");

    ProcessBuilder pb = new ProcessBuilder(
      "psql",
      "-h", host,
      "-p", puerto,
      "-U", usuario,
      "-d", database,
      "-t",
      "-A",
      "-c", """
        SELECT
          'CREATE OR REPLACE VIEW ' || table_name || ' AS' || E'\\n' ||
          view_definition || E';\\n\\n'
        FROM information_schema.views
        WHERE table_schema = 'public'
        ORDER BY table_name
      """
    );

    pb.environment().put("PGPASSWORD", password);

    String resultado = ejecutarComando(pb);

    Files.writeString(directorio.resolve("vistas.sql"),
      "-- ============================================\n" +
      "-- VISTAS\n" +
      "-- ============================================\n\n" +
      resultado.trim());

    log.info("✓ Vistas exportadas");
  }

  private void exportarTriggers(Path directorio, String host, String puerto, String database, String usuario, String password) throws IOException, InterruptedException {
    log.info("Exportando triggers...");

    ProcessBuilder pb = new ProcessBuilder(
      "psql",
      "-h", host,
      "-p", puerto,
      "-U", usuario,
      "-d", database,
      "-t",
      "-A",
      "-c", """
        SELECT pg_get_triggerdef(t.oid) || E';\\n\\n'
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE n.nspname = 'public'
          AND NOT t.tgisinternal
        ORDER BY c.relname, t.tgname
      """
    );

    pb.environment().put("PGPASSWORD", password);

    String resultado = ejecutarComando(pb);

    Files.writeString(directorio.resolve("triggers.sql"),
      "-- ============================================\n" +
      "-- TRIGGERS\n" +
      "-- ============================================\n\n" +
      resultado.trim());

    log.info("✓ Triggers exportados");
  }

  private String ejecutarComando(ProcessBuilder pb) throws IOException, InterruptedException {
    pb.redirectErrorStream(true);
    Process proceso = pb.start();

    StringBuilder salida = new StringBuilder();
    try (BufferedReader reader = new BufferedReader(new InputStreamReader(proceso.getInputStream()))) {
      String linea;
      while ((linea = reader.readLine()) != null) {
        salida.append(linea).append("\n");
      }
    }

    int exitCode = proceso.waitFor();
    if (exitCode != 0) {
      log.warn("Comando terminó con código: {}", exitCode);
    }

    return salida.toString();
  }
}