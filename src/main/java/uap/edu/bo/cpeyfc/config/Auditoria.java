package uap.edu.bo.cpeyfc.config;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Getter
@Setter
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class Auditoria {
  @CreatedDate
  @Column(name = "fecha_reg", nullable = false)
  private LocalDateTime fechaReg;

  @LastModifiedDate
  @Column(name = "fecha_mod")
  private LocalDateTime fechaMod;

  @CreatedBy
  @Column(name = "user_reg", nullable = false)
  private Integer userReg;

  @LastModifiedBy
  @Column(name = "user_mod")
  private Integer userMod;
}