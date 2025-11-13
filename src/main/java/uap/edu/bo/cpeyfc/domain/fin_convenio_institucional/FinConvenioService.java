package uap.edu.bo.cpeyfc.domain.fin_convenio_institucional;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import uap.edu.bo.cpeyfc.domain.fin_descuento_convenio.FinDescuentoConvenioRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FinConvenioService {

  private final FinConvenioInstitucionalRepository finConvenioInstitucionalRepository;
  private final FinDescuentoConvenioRepository finDescuentoConvenioRepository;

  public List<Map<String, Object>> obtenerConveniosVigentes() {
    return finConvenioInstitucionalRepository.vistaConveniosVigentes();
  }

  public List<Map<String, Object>> obtenerConveniosActivos() {
    return finConvenioInstitucionalRepository.obtenerConveniosActivos();
  }

  public List<Map<String, Object>> obtenerDescuentosPorConvenio(Integer idConvenio) {
    return finDescuentoConvenioRepository.obtenerDescuentosPorConvenio(idConvenio);
  }

  @Transactional
  public Integer registrarConvenio(
      String nombreInstitucion,
      String tipoInstitucion,
      String nit,
      String contactoNombre,
      String contactoTelefono,
      String contactoEmail,
      LocalDate fechaInicioConvenio,
      LocalDate fechaFinConvenio,
      String observaciones,
      Integer userReg
  ) {
    return finConvenioInstitucionalRepository.registrarConvenioInstitucional(
        nombreInstitucion,
        tipoInstitucion,
        nit,
        contactoNombre,
        contactoTelefono,
        contactoEmail,
        fechaInicioConvenio,
        fechaFinConvenio,
        observaciones,
        userReg
    );
  }

  @Transactional
  public String modificarConvenio(
      Integer idConvenio,
      String nombreInstitucion,
      String tipoInstitucion,
      String nit,
      String contactoNombre,
      String contactoTelefono,
      String contactoEmail,
      LocalDate fechaInicioConvenio,
      LocalDate fechaFinConvenio,
      String observaciones,
      Integer userMod
  ) {
    return finConvenioInstitucionalRepository.modificarConvenioInstitucional(
        idConvenio,
        nombreInstitucion,
        tipoInstitucion,
        nit,
        contactoNombre,
        contactoTelefono,
        contactoEmail,
        fechaInicioConvenio,
        fechaFinConvenio,
        observaciones,
        userMod
    );
  }

  @Transactional
  public String eliminarConvenio(Integer idConvenio, Integer userMod) {
    return finConvenioInstitucionalRepository.eliminarConvenioInstitucional(idConvenio, userMod);
  }

  @Transactional
  public Integer registrarDescuento(
      Integer idConvenio,
      Integer idProgramaAprobado,
      Integer idFinConceptoPago,
      String tipoDescuento,
      BigDecimal valorDescuento,
      LocalDate fechaInicioVigencia,
      LocalDate fechaFinVigencia,
      String descripcion,
      Integer userReg
  ) {
    return finDescuentoConvenioRepository.registrarDescuentoConvenio(
        idConvenio,
        idProgramaAprobado,
        idFinConceptoPago,
        tipoDescuento,
        valorDescuento,
        fechaInicioVigencia,
        fechaFinVigencia,
        descripcion,
        userReg
    );
  }

  @Transactional
  public String modificarDescuento(
      Integer idDescuentoConvenio,
      String tipoDescuento,
      BigDecimal valorDescuento,
      LocalDate fechaInicioVigencia,
      LocalDate fechaFinVigencia,
      String descripcion,
      String estadoDescuentoConvenio,
      Integer userMod
  ) {
    return finDescuentoConvenioRepository.modificarDescuentoConvenio(
        idDescuentoConvenio,
        tipoDescuento,
        valorDescuento,
        fechaInicioVigencia,
        fechaFinVigencia,
        descripcion,
        estadoDescuentoConvenio,
        userMod
    );
  }

  @Transactional
  public String eliminarDescuento(Integer idDescuentoConvenio, Integer userMod) {
    return finDescuentoConvenioRepository.eliminarDescuentoConvenio(idDescuentoConvenio, userMod);
  }
}
