package com.periferia.prueba.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Check;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Entidad JPA que representa un usuario autenticable de la
 * plataforma: credenciales, documento de identidad, estado
 * (activo/eliminado) y los tokens de acceso y refresco vigentes
 * junto con sus fechas de expiración.
 *
 * @author daniel.barrera
 */
@Entity
@Table(name = "usuario", uniqueConstraints = {
                @UniqueConstraint(name = "uq_usuario_documento", columnNames = { "tipo_documento", "numero_documento" })
}, indexes = {
                @Index(name = "idx_usuario_documento", columnList = "tipo_documento, numero_documento")
})
@Check(name = "chk_usuario_eliminado", constraints = "eliminado in (0, 1)")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Usuario implements Serializable {

        /**
         *
         */
        private static final long serialVersionUID = -1721896203132664972L;

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @Column(nullable = false, unique = true, length = 255)
        private String username;

        @Column(name = "tipo_documento", length = 10)
        private String tipoDocumento;

        @Column(name = "numero_documento", length = 20)
        private String numeroDocumento;

        @Builder.Default
        @Column(nullable = false, columnDefinition = "boolean DEFAULT true")
        private Boolean activo = true;

        @Column(length = 255)
        private String token;

        @Column(length = 255)
        private String password;

        // Ajustado a LocalDateTime para coincidir con 'timestamp without time zone'
        @Column(name = "expirydate")
        private LocalDateTime expiryDate;

        @Builder.Default
        @Column(nullable = false, columnDefinition = "smallint DEFAULT 1")
        private Short eliminado = 1;

        @Column(name = "refresh_token", length = 255, unique = true)
        private String refreshToken;

        @Column(name = "refresh_token_expiry")
        private LocalDateTime refreshTokenExpiry;
}
