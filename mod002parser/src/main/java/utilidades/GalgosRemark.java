package utilidades;

import java.io.Serializable;

public class GalgosRemark implements Serializable {

	private static final long serialVersionUID = 1L;

	public String id;
	public String desc; // descripcion
	public Integer puntos;

	public GalgosRemark(String id, String desc, Integer puntos) {
		super();
		this.id = id;
		this.desc = desc;
		this.puntos = puntos;
	}

}
