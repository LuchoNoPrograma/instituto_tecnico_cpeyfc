package uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;

public interface EjeCronogramaModuloRepository extends JpaRepository<EjeCronogramaModulo, Integer> {
  @Query(value = """
    SELECT fn_modificar_cronograma_modulo(
        :id_eje_cronograma_modulo, :id_prs_persona, :fecha_inicio, :fecha_fin, :user_mod)
    """, nativeQuery = true)
  String modificarCronogramaModulo(Integer id_eje_cronograma_modulo,
                                   Integer id_prs_persona,
                                   LocalDate fecha_inicio,
                                   LocalDate fecha_fin,
                                   Integer user_mod);
}