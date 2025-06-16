package uap.edu.bo.cpeyfc.config;

import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.EnableTransactionManagement;


@Configuration
@EntityScan("uap.edu.bo.cpeyfc")
@EnableJpaRepositories("uap.edu.bo.cpeyfc")
@EnableTransactionManagement
public class DomainConfig {
}
