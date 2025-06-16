package uap.edu.bo.cpeyfc.security;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class RegistrationRequest {

    @NotNull
    @Size(max = 50)
    @RegistrationRequestNombreUsuarioUnique
    private String nombreUsuario;

    @NotNull
    @Size(max = 72)
    private String password;

    @NotNull
    @Size(max = 35)
    private String estadoUsuario;
}
