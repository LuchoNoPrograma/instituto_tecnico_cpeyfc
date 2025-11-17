package uap.edu.bo.cpeyfc.domain.fin_transaccion;

import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;
import uap.edu.bo.cpeyfc.domain.archivo.ArchivoService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Log4j2
@Service
@RequiredArgsConstructor
public class FinTransaccionService {

    private final RepositorioGenericoCrud repositorio;
    private final FinTransaccionRepository finTransaccionRepository;
    private final ArchivoService archivoService;

    /**
     * Registra un pago individual para una obligación de pago
     */
    public Map<String, Object> registrarPagoIndividual(
      MultipartFile voucherFile,
      Integer codMatricula,
      Integer idFinObligacionPago,
      BigDecimal montoPagado,
      LocalDate fechaPago,
      String tipoComprobante,
      String observacion,
      Integer userReg
    ) throws IOException {

        // Guardar voucher si existe
        String voucherUrl = null;
        if (voucherFile != null && !voucherFile.isEmpty()) {
            voucherUrl = archivoService.guardarArchivo(voucherFile, "vouchers");
            log.info("Voucher guardado en: {}", voucherUrl);
        }

        // Registrar el pago usando la función de base de datos
        Map<String, Object> resultado = finTransaccionRepository.registrarPagoIndividual(
          codMatricula,
          idFinObligacionPago,
          montoPagado,
          fechaPago,
          tipoComprobante,
          observacion,
          voucherUrl,
          userReg
        );

        log.info("Pago registrado exitosamente. Comprobante: {}", resultado.get("cod_comprobante"));
        return resultado;
    }

    /**
     * Anula una transacción de pago
     */
    public String anularPago(Integer idTransaccion, String motivoAnulacion, Integer userMod) {
        String resultado = finTransaccionRepository.anularPago(idTransaccion, motivoAnulacion, userMod);
        log.info("Pago anulado: {}", idTransaccion);
        return resultado;
    }

    /**
     * Obtiene el historial de pagos de una matrícula
     */
    public List<Map<String, Object>> historialPagosPorMatricula(Integer codMatricula) {
        return finTransaccionRepository.historialPagosPorMatricula(codMatricula);
    }

    /**
     * Obtiene el historial de todos los pagos
     */
    public List<Map<String, Object>> historialPagosTodos() {
        return finTransaccionRepository.historialPagosTodos();
    }
}
