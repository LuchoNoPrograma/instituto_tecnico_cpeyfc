package uap.edu.bo.cpeyfc.domain.fin_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import uap.edu.bo.cpeyfc.domain.fin_tipo_beneficiario.FinTipoBeneficiarioRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FinArancelService {

  private final FinArancelRepository finArancelRepository;
  private final FinTipoBeneficiarioRepository finTipoBeneficiarioRepository;

  public List<Map<String, Object>> obtenerArancelesVigentes() {
    return finArancelRepository.vistaArancelesVigentes();
  }

  public List<Map<String, Object>> obtenerArancelesPrograma(Integer idProgramaAprobado) {
    return finArancelRepository.obtenerArancelesPrograma(idProgramaAprobado);
  }

  public List<Map<String, Object>> obtenerTiposBeneficiario() {
    return finTipoBeneficiarioRepository.obtenerTiposBeneficiarioActivos();
  }

  @Transactional
  public Integer registrarArancel(
      Integer idFinConceptoPago,
      Integer idProgramaAprobado,
      Integer idTipoBeneficiario,
      BigDecimal montoBase,
      LocalDate fechaInicioVigencia,
      LocalDate fechaFinVigencia,
      String descripcion,
      Integer userReg
  ) {
    return finArancelRepository.registrarArancel(
        idFinConceptoPago,
        idProgramaAprobado,
        idTipoBeneficiario,
        montoBase,
        fechaInicioVigencia,
        fechaFinVigencia,
        descripcion,
        userReg
    );
  }

  @Transactional
  public String modificarArancel(
      Integer idArancel,
      BigDecimal montoBase,
      LocalDate fechaInicioVigencia,
      LocalDate fechaFinVigencia,
      String descripcion,
      Integer userMod
  ) {
    return finArancelRepository.modificarArancel(
        idArancel,
        montoBase,
        fechaInicioVigencia,
        fechaFinVigencia,
        descripcion,
        userMod
    );
  }

  @Transactional
  public String eliminarArancel(Integer idArancel, Integer userMod) {
    return finArancelRepository.eliminarArancel(idArancel, userMod);
  }

  public Map<String, Object> calcularArancelConDescuento(
      Integer idFinConceptoPago,
      Integer idProgramaAprobado,
      Integer idTipoBeneficiario,
      Integer idConvenio
  ) {
    return finArancelRepository.calcularArancelConDescuento(
        idFinConceptoPago,
        idProgramaAprobado,
        idTipoBeneficiario,
        idConvenio
    );
  }
}
