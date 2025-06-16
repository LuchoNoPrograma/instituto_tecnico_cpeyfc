package uap.edu.bo.cpeyfc.security;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class AuthenticationRequest {

    @NotNull
    @Size(max = 50)
    private String nombreUsuario;

    @NotNull
    @Size(max = 72)
    private String password;

}
