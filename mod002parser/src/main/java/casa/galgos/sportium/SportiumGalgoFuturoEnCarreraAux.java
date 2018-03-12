package casa.galgos.sportium;

import java.io.Serializable;

public class SportiumGalgoFuturoEnCarreraAux implements Serializable {

	private static final long serialVersionUID = 1940564997513490524L;

	public Integer trap;
	public String galgoNombre;
	public Float sp; // starting price

	public SportiumGalgoFuturoEnCarreraAux(Integer trap, String galgoNombre, Float sp) {
		super();
		this.trap = trap;
		this.galgoNombre = galgoNombre;
		this.sp = sp;
	}

}
