package com.periferia.prueba.model;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "publicacion_adjunto")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PublicacionAdjunto implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "publicacion_id", nullable = false, foreignKey = @ForeignKey(name = "fk_adjunto_publicacion"))
    private Publicacion publicacion;

    @Column(name = "url_archivo", nullable = false, length = 500)
    private String urlArchivo;

    @Column(name = "tipo_mime", length = 50)
    private String tipoMime;

    @Builder.Default
    @Column(name = "creado_en", nullable = false, columnDefinition = "timestamp DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime creadoEn = LocalDateTime.now();
}
