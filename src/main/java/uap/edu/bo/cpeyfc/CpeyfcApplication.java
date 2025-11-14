package uap.edu.bo.cpeyfc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;


@SpringBootApplication
@EnableScheduling
public class CpeyfcApplication {

    public static void main(final String[] args) {
        SpringApplication.run(CpeyfcApplication.class, args);
    }

}
