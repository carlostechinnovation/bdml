package casa.galgos.sportium;

import java.io.Serializable;

public class SportiumGalgoFuturoEnCarreraAux implements Serializable {

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
