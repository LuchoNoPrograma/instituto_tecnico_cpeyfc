# 📋 TAREAS DE IMPLEMENTACIÓN - Sistema de Aranceles y Convenios

## 🎯 Objetivo
Implementar el sistema completo de gestión de aranceles diferenciados por tipo de beneficiario y convenios institucionales en la aplicación Spring Boot + Vue.js.

---

## 📦 BACKEND - Spring Boot

### 1️⃣ ENTIDADES (Entities)

**Ubicación:** `src/main/java/uap/edu/bo/cpeyfc/domain/`

#### 📄 Crear: `fin_tipo_beneficiario/FinTipoBeneficiario.java`
```java
package uap.edu.bo.cpeyfc.domain.fin_tipo_beneficiario;

import lombok.Data;
import javax.persistence.*;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "fin_tipo_beneficiario")
public class FinTipoBeneficiario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_tipo_beneficiario")
    private Integer idTipoBeneficiario;

@Column(name = "nombre_tipo", nullable = false, length = 100)
    private String nombreTipo;

@Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

@Column(name = "estado_tipo_beneficiario", nullable = false, length = 20)
    private String estadoTipoBeneficiario;

@Column(name = "fecha_reg", nullable = false)
    private LocalDateTime fechaReg;

@Column(name = "user_reg", nullable = false)
    private Integer userReg;

@Column(name = "fecha_mod")
    private LocalDateTime fechaMod;

@Column(name = "user_mod")
    private Integer userMod;
}
```

#### 📄 Crear: `fin_arancel/FinArancel.java`
```java
package uap.edu.bo.cpeyfc.domain.fin_arancel;

import lombok.Data;
import uap.edu.bo.cpeyfc.domain.aca_programa.AcaProgramaAprobado;
import uap.edu.bo.cpeyfc.domain.fin_concepto_pago.FinConceptoPago;
import uap.edu.bo.cpeyfc.domain.fin_tipo_beneficiario.FinTipoBeneficiario;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "fin_arancel")
public class FinArancel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_arancel")
    private Integer idArancel;

@ManyToOne
    @JoinColumn(name = "id_fin_concepto_pago", nullable = false)
    private FinConceptoPago finConceptoPago;

@ManyToOne
    @JoinColumn(name = "id_aca_programa_aprobado")
    private AcaProgramaAprobado acaProgramaAprobado;

@ManyToOne
    @JoinColumn(name = "id_tipo_beneficiario", nullable = false)
    private FinTipoBeneficiario tipoBeneficiario;

@Column(name = "monto_base", nullable = false, precision = 10, scale = 2)
    private BigDecimal montoBase;

@Column(name = "fecha_inicio_vigencia", nullable = false)
    private LocalDate fechaInicioVigencia;

@Column(name = "fecha_fin_vigencia")
    private LocalDate fechaFinVigencia;

@Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

@Column(name = "estado_arancel", nullable = false, length = 20)
    private String estadoArancel;

@Column(name = "fecha_reg", nullable = false)
    private LocalDateTime fechaReg;

@Column(name = "user_reg", nullable = false)
    private Integer userReg;

@Column(name = "fecha_mod")
    private LocalDateTime fechaMod;

@Column(name = "user_mod")
    private Integer userMod;
}
```

#### 📄 Crear: `fin_convenio_institucional/FinConvenioInstitucional.java`
```java
package uap.edu.bo.cpeyfc.domain.fin_convenio_institucional;

import lombok.Data;
import javax.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "fin_convenio_institucional")
public class FinConvenioInstitucional {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_convenio")
    private Integer idConvenio;

@Column(name = "nombre_institucion", nullable = false, length = 200)
    private String nombreInstitucion;

@Column(name = "tipo_institucion", nullable = false, length = 50)
    private String tipoInstitucion;

@Column(name = "nit", length = 20)
    private String nit;

@Column(name = "contacto_nombre", length = 150)
    private String contactoNombre;

@Column(name = "contacto_telefono", length = 20)
    private String contactoTelefono;

@Column(name = "contacto_email", length = 100)
    private String contactoEmail;

@Column(name = "fecha_inicio_convenio", nullable = false)
    private LocalDate fechaInicioConvenio;

@Column(name = "fecha_fin_convenio")
    private LocalDate fechaFinConvenio;

@Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;

@Column(name = "estado_convenio", nullable = false, length = 20)
    private String estadoConvenio;

@Column(name = "fecha_reg", nullable = false)
    private LocalDateTime fechaReg;

@Column(name = "user_reg", nullable = false)
    private Integer userReg;

@Column(name = "fecha_mod")
    private LocalDateTime fechaMod;

@Column(name = "user_mod")
    private Integer userMod;
}
```

#### 📄 Crear: `fin_descuento_convenio/FinDescuentoConvenio.java`
```java
package uap.edu.bo.cpeyfc.domain.fin_descuento_convenio;

import lombok.Data;
import uap.edu.bo.cpeyfc.domain.aca_programa.AcaProgramaAprobado;
import uap.edu.bo.cpeyfc.domain.fin_concepto_pago.FinConceptoPago;
import uap.edu.bo.cpeyfc.domain.fin_convenio_institucional.FinConvenioInstitucional;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "fin_descuento_convenio")
public class FinDescuentoConvenio {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_descuento_convenio")
    private Integer idDescuentoConvenio;

@ManyToOne
    @JoinColumn(name = "id_convenio", nullable = false)
    private FinConvenioInstitucional convenio;

@ManyToOne
    @JoinColumn(name = "id_aca_programa_aprobado")
    private AcaProgramaAprobado acaProgramaAprobado;

@ManyToOne
    @JoinColumn(name = "id_fin_concepto_pago")
    private FinConceptoPago finConceptoPago;

@Column(name = "tipo_descuento", nullable = false, length = 20)
    private String tipoDescuento;

@Column(name = "valor_descuento", nullable = false, precision = 10, scale = 2)
    private BigDecimal valorDescuento;

@Column(name = "fecha_inicio_vigencia", nullable = false)
    private LocalDate fechaInicioVigencia;

@Column(name = "fecha_fin_vigencia")
    private LocalDate fechaFinVigencia;

@Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

@Column(name = "estado_descuento_convenio", nullable = false, length = 20)
    private String estadoDescuentoConvenio;

@Column(name = "fecha_reg", nullable = false)
    private LocalDateTime fechaReg;

@Column(name = "user_reg", nullable = false)
    private Integer userReg;

@Column(name = "fecha_mod")
    private LocalDateTime fechaMod;

@Column(name = "user_mod")
    private Integer userMod;
}
```

---

### 2️⃣ REPOSITORIOS (Repositories)

**Ubicación:** `src/main/java/uap/edu/bo/cpeyfc/domain/{tabla}/`

#### 📄 Crear: `fin_tipo_beneficiario/FinTipoBeneficiarioRepository.java`
```java
package uap.edu.bo.cpeyfc.domain.fin_tipo_beneficiario;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Map;

@Repository
public interface FinTipoBeneficiarioRepository extends JpaRepository<FinTipoBeneficiario, Integer> {
    
    @Query(nativeQuery = true, value = """
        SELECT * FROM fin_tipo_beneficiario 
        WHERE estado_tipo_beneficiario != 'ELIMINADO'
        ORDER BY nombre_tipo
        """)
    List<Map<String, Object>> obtenerTiposBeneficiarioActivos();

@Query(nativeQuery = true, value = """
        SELECT fn_registrar_tipo_beneficiario(:nombre_tipo, :descripcion, :user_reg)
        """)
    Integer registrarTipoBeneficiario(String nombre_tipo, String descripcion, Integer user_reg);

@Query(nativeQuery = true, value = """
        SELECT fn_modificar_tipo_beneficiario(
            :id_tipo_beneficiario, :nombre_tipo, :descripcion, 
            :estado_tipo_beneficiario, :user_mod
        )
        """)
    String modificarTipoBeneficiario(
        Integer id_tipo_beneficiario,
        String nombre_tipo,
        String descripcion,
        String estado_tipo_beneficiario,
        Integer user_mod
    );

@Query(nativeQuery = true, value = """
        SELECT fn_eliminar_tipo_beneficiario(:id_tipo_beneficiario, :user_mod)
        """)
    String eliminarTipoBeneficiario(Integer id_tipo_beneficiario, Integer user_mod);
}
```

#### 📄 Crear: `fin_arancel/FinArancelRepository.java`
```java
package uap.edu.bo.cpeyfc.domain.fin_arancel;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public interface FinArancelRepository extends JpaRepository<FinArancel, Integer> {

    @Query(nativeQuery = true, value = "SELECT * FROM vista_aranceles_vigentes")
    List<Map<String, Object>> vistaArancelesVigentes();

@Query(nativeQuery = true, value = """
        SELECT * FROM fn_obtener_aranceles_programa(:id_programa_aprobado)
        """)
    List<Map<String, Object>> obtenerArancelesPrograma(Integer id_programa_aprobado);

@Query(nativeQuery = true, value = """
        SELECT fn_registrar_arancel(
            :id_fin_concepto_pago, :id_programa_aprobado, :id_tipo_beneficiario,
            :monto_base, :fecha_inicio_vigencia, :fecha_fin_vigencia,
            :descripcion, :user_reg
        )
        """)
    Integer registrarArancel(
        Integer id_fin_concepto_pago,
        Integer id_programa_aprobado,
        Integer id_tipo_beneficiario,
        BigDecimal monto_base,
        LocalDate fecha_inicio_vigencia,
        LocalDate fecha_fin_vigencia,
        String descripcion,
        Integer user_reg
    );

@Query(nativeQuery = true, value = """
        SELECT fn_modificar_arancel(
            :id_arancel, :monto_base, :fecha_inicio_vigencia,
            :fecha_fin_vigencia, :descripcion, :estado_arancel, :user_mod
        )
        """)
    String modificarArancel(
        Integer id_arancel,
        BigDecimal monto_base,
        LocalDate fecha_inicio_vigencia,
        LocalDate fecha_fin_vigencia,
        String descripcion,
        String estado_arancel,
        Integer user_mod
    );

@Query(nativeQuery = true, value = """
        SELECT fn_eliminar_arancel(:id_arancel, :user_mod)
        """)
    String eliminarArancel(Integer id_arancel, Integer user_mod);

@Query(nativeQuery = true, value = """
        SELECT * FROM fn_calcular_arancel_con_descuento(
            :id_fin_concepto_pago, :id_programa_aprobado,
            :id_tipo_beneficiario, :id_convenio
        )
        """)
    Map<String, Object> calcularArancelConDescuento(
        Integer id_fin_concepto_pago,
        Integer id_programa_aprobado,
        Integer id_tipo_beneficiario,
        Integer id_convenio
    );
}
```

#### 📄 Crear: `fin_convenio_institucional/FinConvenioInstitucionalRepository.java`
```java
package uap.edu.bo.cpeyfc.domain.fin_convenio_institucional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public interface FinConvenioInstitucionalRepository extends JpaRepository<FinConvenioInstitucional, Integer> {

    @Query(nativeQuery = true, value = "SELECT * FROM vista_convenios_vigentes")
    List<Map<String, Object>> vistaConveniosVigentes();

@Query(nativeQuery = true, value = """
        SELECT * FROM fin_convenio_institucional 
        WHERE estado_convenio != 'ELIMINADO'
        ORDER BY nombre_institucion
        """)
    List<Map<String, Object>> obtenerConveniosActivos();

@Query(nativeQuery = true, value = """
        SELECT fn_registrar_convenio_institucional(
            :nombre_institucion, :tipo_institucion, :nit,
            :contacto_nombre, :contacto_telefono, :contacto_email,
            :fecha_inicio_convenio, :fecha_fin_convenio,
            :observaciones, :user_reg
        )
        """)
    Integer registrarConvenioInstitucional(
        String nombre_institucion,
        String tipo_institucion,
        String nit,
        String contacto_nombre,
        String contacto_telefono,
        String contacto_email,
        LocalDate fecha_inicio_convenio,
        LocalDate fecha_fin_convenio,
        String observaciones,
        Integer user_reg
    );

@Query(nativeQuery = true, value = """
        SELECT fn_modificar_convenio_institucional(
            :id_convenio, :nombre_institucion, :tipo_institucion, :nit,
            :contacto_nombre, :contacto_telefono, :contacto_email,
            :fecha_inicio_convenio, :fecha_fin_convenio,
            :observaciones, :estado_convenio, :user_mod
        )
        """)
    String modificarConvenioInstitucional(
        Integer id_convenio,
        String nombre_institucion,
        String tipo_institucion,
        String nit,
        String contacto_nombre,
        String contacto_telefono,
        String contacto_email,
        LocalDate fecha_inicio_convenio,
        LocalDate fecha_fin_convenio,
        String observaciones,
        String estado_convenio,
        Integer user_mod
    );

@Query(nativeQuery = true, value = """
        SELECT fn_eliminar_convenio_institucional(:id_convenio, :user_mod)
        """)
    String eliminarConvenioInstitucional(Integer id_convenio, Integer user_mod);
}
```

#### 📄 Crear: `fin_descuento_convenio/FinDescuentoConvenioRepository.java`
```java
package uap.edu.bo.cpeyfc.domain.fin_descuento_convenio;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public interface FinDescuentoConvenioRepository extends JpaRepository<FinDescuentoConvenio, Integer> {

    @Query(nativeQuery = true, value = """
        SELECT * FROM fin_descuento_convenio 
        WHERE id_convenio = :id_convenio 
        AND estado_descuento_convenio != 'ELIMINADO'
        ORDER BY fecha_inicio_vigencia DESC
        """)
    List<Map<String, Object>> obtenerDescuentosPorConvenio(Integer id_convenio);

@Query(nativeQuery = true, value = """
        SELECT fn_registrar_descuento_convenio(
            :id_convenio, :id_programa_aprobado, :id_fin_concepto_pago,
            :tipo_descuento, :valor_descuento, :fecha_inicio_vigencia,
            :fecha_fin_vigencia, :descripcion, :user_reg
        )
        """)
    Integer registrarDescuentoConvenio(
        Integer id_convenio,
        Integer id_programa_aprobado,
        Integer id_fin_concepto_pago,
        String tipo_descuento,
        BigDecimal valor_descuento,
        LocalDate fecha_inicio_vigencia,
        LocalDate fecha_fin_vigencia,
        String descripcion,
        Integer user_reg
    );

@Query(nativeQuery = true, value = """
        SELECT fn_modificar_descuento_convenio(
            :id_descuento_convenio, :tipo_descuento, :valor_descuento,
            :fecha_inicio_vigencia, :fecha_fin_vigencia, :descripcion,
            :estado_descuento_convenio, :user_mod
        )
        """)
    String modificarDescuentoConvenio(
        Integer id_descuento_convenio,
        String tipo_descuento,
        BigDecimal valor_descuento,
        LocalDate fecha_inicio_vigencia,
        LocalDate fecha_fin_vigencia,
        String descripcion,
        String estado_descuento_convenio,
        Integer user_mod
    );

@Query(nativeQuery = true, value = """
        SELECT fn_eliminar_descuento_convenio(:id_descuento_convenio, :user_mod)
        """)
    String eliminarDescuentoConvenio(Integer id_descuento_convenio, Integer user_mod);
}
```

---

### 3️⃣ SERVICIOS (Services)

**Ubicación:** `src/main/java/uap/edu/bo/cpeyfc/service/`

#### 📄 Crear: `FinArancelService.java`
```java
package uap.edu.bo.cpeyfc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import uap.edu.bo.cpeyfc.domain.fin_arancel.FinArancelRepository;
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
            String estadoArancel,
            Integer userMod
    ) {
        return finArancelRepository.modificarArancel(
            idArancel,
            montoBase,
            fechaInicioVigencia,
            fechaFinVigencia,
            descripcion,
            estadoArancel,
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
```

#### 📄 Crear: `FinConvenioService.java`
```java
package uap.edu.bo.cpeyfc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import uap.edu.bo.cpeyfc.domain.fin_convenio_institucional.FinConvenioInstitucionalRepository;
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
            String estadoConvenio,
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
            estadoConvenio,
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
```

---

### 4️⃣ CONTROLADORES (Controllers)

**Ubicación:** `src/main/java/uap/edu/bo/cpeyfc/controller/`

#### 📄 Crear: `FinArancelController.java`
```java
package uap.edu.bo.cpeyfc.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.config.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.service.FinArancelService;
import uap.edu.bo.cpeyfc.utils.FechaUtil;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class FinArancelController {

    private final FinArancelService finArancelService;

@GetMapping("/api/aranceles/vigentes")
    public ResponseEntity<?> obtenerArancelesVigentes() {
        return ResponseEntity.ok(finArancelService.obtenerArancelesVigentes());
}

    @GetMapping("/api/aranceles/programa/{idPrograma}")
    public ResponseEntity<?> obtenerArancelesPrograma(@PathVariable Integer idPrograma) {
        return ResponseEntity.ok(finArancelService.obtenerArancelesPrograma(idPrograma));
}

    @GetMapping("/api/tipos-beneficiario")
    public ResponseEntity<?> obtenerTiposBeneficiario() {
        return ResponseEntity.ok(finArancelService.obtenerTiposBeneficiario());
}

    @PostMapping("/api/arancel")
    public ResponseEntity<?> registrarArancel(
            @RequestBody Map<String, Object> datos,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        Integer idArancel = finArancelService.registrarArancel(
            (Integer) datos.get("idFinConceptoPago"),
            (Integer) datos.get("idProgramaAprobado"),
            (Integer) datos.get("idTipoBeneficiario"),
            new BigDecimal(datos.get("montoBase").toString()),
            FechaUtil.toLocalDate(datos.get("fechaInicioVigencia")),
            FechaUtil.toLocalDate(datos.get("fechaFinVigencia")),
            (String) datos.get("descripcion"),
            userDetails.getIdSegUsuario()
        );

return ResponseEntity.ok(Map.of(
            "idArancel", idArancel,
            "mensaje", "Arancel registrado exitosamente"
        ));
}

    @PutMapping("/api/arancel/{idArancel}")
    public ResponseEntity<?> modificarArancel(
            @PathVariable Integer idArancel,
            @RequestBody Map<String, Object> datos,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        String mensaje = finArancelService.modificarArancel(
            idArancel,
            new BigDecimal(datos.get("montoBase").toString()),
            FechaUtil.toLocalDate(datos.get("fechaInicioVigencia")),
            FechaUtil.toLocalDate(datos.get("fechaFinVigencia")),
            (String) datos.get("descripcion"),
            (String) datos.get("estadoArancel"),
            userDetails.getIdSegUsuario()
        );

return ResponseEntity.ok(Map.of("mensaje", mensaje));
}

    @DeleteMapping("/api/arancel/{idArancel}")
    public ResponseEntity<?> eliminarArancel(
            @PathVariable Integer idArancel,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        String mensaje = finArancelService.eliminarArancel(idArancel, userDetails.getIdSegUsuario());
return ResponseEntity.ok(Map.of("mensaje", mensaje));
}

    @PostMapping("/api/arancel/calcular")
    public ResponseEntity<?> calcularArancelConDescuento(@RequestBody Map<String, Object> datos) {
        Map<String, Object> resultado = finArancelService.calcularArancelConDescuento(
            (Integer) datos.get("idFinConceptoPago"),
            (Integer) datos.get("idProgramaAprobado"),
            (Integer) datos.get("idTipoBeneficiario"),
            (Integer) datos.get("idConvenio")
        );
return ResponseEntity.ok(resultado);
}
}
```

#### 📄 Crear: `FinConvenioController.java`
```java
package uap.edu.bo.cpeyfc.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.config.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.service.FinConvenioService;
import uap.edu.bo.cpeyfc.utils.FechaUtil;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class FinConvenioController {

    private final FinConvenioService finConvenioService;

@GetMapping("/api/convenios/vigentes")
    public ResponseEntity<?> obtenerConveniosVigentes() {
        return ResponseEntity.ok(finConvenioService.obtenerConveniosVigentes());
}

    @GetMapping("/api/convenios/activos")
    public ResponseEntity<?> obtenerConveniosActivos() {
        return ResponseEntity.ok(finConvenioService.obtenerConveniosActivos());
}

    @GetMapping("/api/convenio/{idConvenio}/descuentos")
    public ResponseEntity<?> obtenerDescuentosPorConvenio(@PathVariable Integer idConvenio) {
        return ResponseEntity.ok(finConvenioService.obtenerDescuentosPorConvenio(idConvenio));
}

    @PostMapping("/api/convenio")
    public ResponseEntity<?> registrarConvenio(
            @RequestBody Map<String, Object> datos,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        Integer idConvenio = finConvenioService.registrarConvenio(
            (String) datos.get("nombreInstitucion"),
            (String) datos.get("tipoInstitucion"),
            (String) datos.get("nit"),
            (String) datos.get("contactoNombre"),
            (String) datos.get("contactoTelefono"),
            (String) datos.get("contactoEmail"),
            FechaUtil.toLocalDate(datos.get("fechaInicioConvenio")),
            FechaUtil.toLocalDate(datos.get("fechaFinConvenio")),
            (String) datos.get("observaciones"),
            userDetails.getIdSegUsuario()
        );

return ResponseEntity.ok(Map.of(
            "idConvenio", idConvenio,
            "mensaje", "Convenio registrado exitosamente"
        ));
}

    @PutMapping("/api/convenio/{idConvenio}")
    public ResponseEntity<?> modificarConvenio(
            @PathVariable Integer idConvenio,
            @RequestBody Map<String, Object> datos,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        String mensaje = finConvenioService.modificarConvenio(
            idConvenio,
            (String) datos.get("nombre_institucion"),
            (String) datos.get("tipo_institucion"),
            (String) datos.get("nit"),
            (String) datos.get("contacto_nombre"),
            (String) datos.get("contacto_telefono"),
            (String) datos.get("contacto_email"),
            FechaUtil.toLocalDate(datos.get("fecha_inicio_convenio")),
            FechaUtil.toLocalDate(datos.get("fecha_fin_convenio")),
            (String) datos.get("observaciones");
            userDetails.getIdSegUsuario();
        );

return ResponseEntity.ok(Map.of("mensaje", mensaje));
}

    @DeleteMapping("/api/convenio/{idConvenio}")
    public ResponseEntity<?> eliminarConvenio(
            @PathVariable Integer idConvenio,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        String mensaje = finConvenioService.eliminarConvenio(idConvenio, userDetails.getIdSegUsuario());
return ResponseEntity.ok(Map.of("mensaje", mensaje));
}

    @PostMapping("/api/convenio/descuento")
    public ResponseEntity<?> registrarDescuento(
            @RequestBody Map<String, Object> datos,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        Integer idDescuento = finConvenioService.registrarDescuento(
            (Integer) datos.get("id_convenio"),
            (Integer) datos.get("id_aca_programa_aprobado"),
            (Integer) datos.get("id_fin_concepto_pago"),
            (String) datos.get("tipo_descuento"),
            new BigDecimal(datos.get("valor_descuento").toString()),
            FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
            FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
            (String) datos.get("descripcion"),
            userDetails.getIdSegUsuario()
        );

return ResponseEntity.ok(Map.of(
            "idDescuento", idDescuento,
            "mensaje", "Descuento registrado exitosamente"
        ));
}

    @PutMapping("/api/convenio/descuento/{idDescuento}")
    public ResponseEntity<?> modificarDescuento(
            @PathVariable Integer idDescuento,
            @RequestBody Map<String, Object> datos,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        String mensaje = finConvenioService.modificarDescuento(
            idDescuento,
            (String) datos.get("tipo_descuento"),
            new BigDecimal(datos.get("valor_descuento").toString()),
            FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
            FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
            (String) datos.get("descripcion"),
            userDetails.getIdSegUsuario()
        );

return ResponseEntity.ok(Map.of("mensaje", mensaje));
}

    @DeleteMapping("/api/convenio/descuento/{idDescuento}")
    public ResponseEntity<?> eliminarDescuento(
            @PathVariable Integer idDescuento,
            @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        String mensaje = finConvenioService.eliminarDescuento(idDescuento, userDetails.getIdSegUsuario());
return ResponseEntity.ok(Map.of("mensaje", mensaje));
}
}
```

---

## 🎨 FRONTEND - Vue.js + Vuetify

### 5️⃣ COMPONENTES DE GESTIÓN

**Ubicación:** `src/components/` (o donde tengas tus componentes Vue)

#### 📄 Crear: `ListaAranceles.vue`
Componente principal para gestionar aranceles con:
- Tabla de aranceles vigentes (usando `v-data-table`)
- Botón "Nuevo Arancel" que abre diálogo
- Acciones: Editar, Eliminar
- Filtros por programa, concepto, tipo beneficiario
- Búsqueda por texto

Características:
- Usar `v-dialog` para formularios de registro/edición
- Usar `v-select` para seleccionar programa, concepto, tipo beneficiario
            - Usar `v-text-field` con `type="number"` para montos
- Usar `v-date-picker` para fechas (integrado con Vuetify)
- Validaciones de formulario con reglas
- Confirmación con SweetAlert2 antes de eliminar
- Loading states con `v-progress-linear`

#### 📄 Crear: `ListaConvenios.vue`
Componente principal para gestionar convenios con:
- Tabla de convenios vigentes
- Botón "Nuevo Convenio" que abre diálogo
- Sub-tabla expandible con descuentos asociados
- Acciones: Editar, Eliminar, Agregar Descuento
            - Filtros por tipo de institución, vigencia

    Características similares a `GestionAranceles.vue`

#### 📄 Crear: `FormularioArancel.vue`
Componente de formulario reutilizable para crear/editar aranceles-> Inspirate en ListaProgramas.vue

#### 📄 Crear: `FormularioConvenio.vue` Similar estructura al formulario de arancel pero para convenios

### 6️⃣ INTEGRACIÓN CON VISTA EXISTENTE

**Tarea:** Agregar nuevas opciones de menú en tu vista administrativa

Pasos:
1. Identificar el componente de menú principal (probablemente en `views/` o `layouts/`)
2. Agregar ítems de menú:
   ```javascript
   {
     title: 'Gestión Financiera',
     icon: 'mdi-currency-usd',
     children: [
       {
         title: 'Aranceles',
         to: '/aranceles',
         icon: 'mdi-cash-multiple'
       },
       {
         title: 'Convenios',
         to: '/convenios',
         icon: 'mdi-handshake'
       }
     ]
   }
   ```

3. Configurar rutas en el router (`src/router/index.js` o similar):
   ```javascript
   {
     path: '/aranceles',
     name: 'Aranceles',
     component: () => import('@/components/GestionAranceles.vue'),
  meta: { requiresAuth: true, roles: ['ADMIN'] }
  },
  {
  path: '/convenios',
  name: 'Convenios',
  component: () => import('@/components/GestionConvenios.vue'),
  meta: { requiresAuth: true, roles: ['ADMIN'] }
  }
  ```

  ## ✅ CHECKLIST DE IMPLEMENTACIÓN

  ### Backend:
  - [ ] Crear 4 entidades (FinTipoBeneficiario, FinArancel, FinConvenioInstitucional, FinDescuentoConvenio)
  - [ ] Crear 4 repositorios con métodos nativos
  - [ ] Crear 2 servicios (FinArancelService, FinConvenioService)
  - [ ] Crear 2 controladores (FinArancelApi, FinConvenioApi)

  ### Frontend:
  - [ ] Crear componentes de gestión (ListaAranceles.vue, ListaConvenios.vue)
  - [ ] Crear formularios (FormularioArancel.vue, FormularioConvenio.vue)
  - [ ] Agregar rutas en el router
  - [ ] Agregar ítems de menú
  - [ ] Implementar validaciones y manejo de errores
  - [ ] Agregar loading states y feedback al usuario
```

  ## 📝 NOTAS IMPORTANTES

  1. **Convenciones de código:**
  - Backend: camelCase para métodos Java, snake_case para SQL
  - Frontend: camelCase para JavaScript, pero en snake_case la data que viene del backend relacionada a tablas SQL
  - Sin anotación `@Param` en repositorios
  - Usar `FechaUtil` para conversión de fechas

  2. **Manejo de errores:**
  - Las funciones SQL lanzan excepciones con mensajes descriptivos
  - Capturar excepciones en el frontend y mostrar con SweetAlert2

  3. **Estados:**
  - Soft delete: cambiar estado a 'ELIMINADO'

           4. **Fechas:**
           - Backend: LocalDate para fechas, LocalDateTime para timestamps
           - Frontend: Usar Vuetify date picker o moment.js

           5. **Permisos:**
           - Configurar roles apropiados en rutas (ADMIN, FINANCIERO)
           - Validar permisos en el backend con Spring Security
---

  ## 🚀 ORDEN SUGERIDO DE IMPLEMENTACIÓN

1. Backend completo (entidades → repos → services → controllers)
2. Probar endpoints con Postman
3. Crear datos de prueba en BD
4. Frontend: servicios de API
5. Frontend: componentes de gestión
6. Frontend: integración con menú y rutas
7. Pruebas end-to-end
8. Ajustes y refinamiento UX

---

¡Listo para comenzar! 🎉