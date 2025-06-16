package uap.edu.bo.cpeyfc.security;

import static org.junit.jupiter.api.Assertions.assertEquals;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import uap.edu.bo.cpeyfc.config.BaseIT;


public class RegistrationApiTest extends BaseIT {

    @Test
    void register_success() {
        RestAssured
                .given()
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .body(readResource("/requests/registrationRequest.json"))
                .when()
                    .post("/register")
                .then()
                    .statusCode(HttpStatus.OK.value());
            assertEquals(3, segUsuarioRepository.count());
        }

    }
