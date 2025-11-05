package uap.edu.bo.cpeyfc.config;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.format.DateTimeFormatter;
import java.util.TimeZone;


@Configuration
public class JacksonConfig {

  @Bean
  public Jackson2ObjectMapperBuilderCustomizer jacksonCustomizer() {
    return jacksonObjectMapperBuilder -> {

      // Configurar zona horaria
      jacksonObjectMapperBuilder.timeZone(TimeZone.getTimeZone("America/La_Paz"));

      // Módulo de JavaTime con deserializadores personalizados
      JavaTimeModule javaTimeModule = new JavaTimeModule();

      // LocalDate - acepta ISO_DATE_TIME pero extrae solo la fecha
      javaTimeModule.addDeserializer(
        java.time.LocalDate.class,
        new LocalDateDeserializer(DateTimeFormatter.ISO_DATE_TIME)
      );
      javaTimeModule.addSerializer(
        java.time.LocalDate.class,
        new LocalDateSerializer(DateTimeFormatter.ISO_LOCAL_DATE)
      );

      // LocalDateTime - acepta ISO_DATE_TIME completo
      javaTimeModule.addDeserializer(
        java.time.LocalDateTime.class,
        new LocalDateTimeDeserializer(DateTimeFormatter.ISO_DATE_TIME)
      );
      javaTimeModule.addSerializer(
        java.time.LocalDateTime.class,
        new LocalDateTimeSerializer(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
      );

      jacksonObjectMapperBuilder
        .modules(javaTimeModule)
        .featuresToDisable(
          DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES,
          DeserializationFeature.ACCEPT_FLOAT_AS_INT,
          SerializationFeature.WRITE_DATES_AS_TIMESTAMPS
        )
        .featuresToEnable(
          DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE
        );
    };
  }

}
