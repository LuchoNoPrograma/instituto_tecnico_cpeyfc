package uap.edu.bo.cpeyfc.security;

import static java.lang.annotation.ElementType.ANNOTATION_TYPE;
import static java.lang.annotation.ElementType.FIELD;
import static java.lang.annotation.ElementType.METHOD;

import jakarta.validation.Constraint;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import jakarta.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;


/**
 * Validate that the nombreUsuario value isn't taken yet.
 */
@Target({ FIELD, METHOD, ANNOTATION_TYPE })
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Constraint(
        validatedBy = RegistrationRequestNombreUsuarioUnique.RegistrationRequestNombreUsuarioUniqueValidator.class
)
public @interface RegistrationRequestNombreUsuarioUnique {

    String message() default "{registration.register.taken}";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};

    class RegistrationRequestNombreUsuarioUniqueValidator implements ConstraintValidator<RegistrationRequestNombreUsuarioUnique, String> {

        private final RegistrationService registrationService;

        public RegistrationRequestNombreUsuarioUniqueValidator(
                final RegistrationService registrationService) {
            this.registrationService = registrationService;
        }

        @Override
        public boolean isValid(final String value, final ConstraintValidatorContext cvContext) {
            if (value == null) {
                // no value present
                return true;
            }
            return !registrationService.nombreUsuarioExists(value);
        }

    }

}
