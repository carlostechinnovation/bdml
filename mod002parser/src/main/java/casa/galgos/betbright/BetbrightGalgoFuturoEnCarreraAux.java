package casa.galgos.betbright;

import java.io.Serializable;

public class BetbrightGalgoFuturoEnCarreraAux implements Serializable {

	public Integer trap;
	public String galgoNombre;
	public Float sp; // starting price

	public BetbrightGalgoFuturoEnCarreraAux(Integer trap, String galgoNombre, Float sp) {
		super();
		this.trap = trap;
		this.galgoNombre = galgoNombre;
		this.sp = sp;
	}

}
