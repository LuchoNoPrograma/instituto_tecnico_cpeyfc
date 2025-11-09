package uap.edu.bo.cpeyfc.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class WebConfig implements WebMvcConfigurer {

  @Value("${app.uploads.path}")
  private String uploadsPath;

  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    Path proyectoPath = Paths.get("").toAbsolutePath();
    Path uploadsAbsolutePath = proyectoPath.resolve(uploadsPath);

    registry
      .addResourceHandler("/uploads/**")
      .addResourceLocations("file:" + uploadsAbsolutePath + "/");
  }
}