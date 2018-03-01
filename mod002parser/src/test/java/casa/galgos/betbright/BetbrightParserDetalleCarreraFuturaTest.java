package casa.galgos.betbright;

import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;

/**
 * @author root
 *
 */
public class BetbrightParserDetalleCarreraFuturaTest {

	@Before
	public void iniciar() {
	}

	@Rule
	// public ResourceFile resFuturo = new ResourceFile("/" +
	// "betbright_carrera_futura.html");
	public ResourceFile resFuturo = new ResourceFile("/" + "detalle_bb.html");

	@Rule
	public ResourceFile resFuturoNula = new ResourceFile("/" + "betbright_carrera_futura_NULA.html");

	@Rule
	public ResourceFile resFuturoConSP = new ResourceFile("/" + "betbright_carrera_futura_CON_SP.html");

	@Rule
	public ResourceFile resFuturoConGalgoEliminado = new ResourceFile(
			"/" + "betbright_carrera_futura_CON_ELIMINADO.html");

	@Test
	public void parsearCarreraFuturaTest() throws Exception {

		String contenidoWeb = resFuturo.getContent("ISO-8859-1");

		CarreraSemillaBetbright carreraIn = new CarreraSemillaBetbright("URL_previa_conocida", null, null, null, null,
				null, new ArrayList<CarreraGalgoSemillaBetbright>());

		BetbrightParserDetalleCarreraFutura.parsear(contenidoWeb, carreraIn);

		Assert.assertTrue(carreraIn != null && !carreraIn.listaCG.isEmpty());
		Assert.assertTrue(carreraIn.listaCG.size() == 6);
		Assert.assertTrue(carreraIn.distancia != null);

		for (CarreraGalgoSemillaBetbright item : carreraIn.listaCG) {
			Assert.assertTrue(item != null);
			Assert.assertTrue(item.galgoNombre != null && !item.galgoNombre.isEmpty());
		}
	}

	@Test
	public void parsearCarreraFuturaNulaTest() throws Exception {

		String contenidoWeb = resFuturoNula.getContent("ISO-8859-1");

		CarreraSemillaBetbright carreraIn = new CarreraSemillaBetbright("URL_previa_conocida", null, null, null, null,
				null, new ArrayList<CarreraGalgoSemillaBetbright>());

		BetbrightParserDetalleCarreraFutura.parsear(contenidoWeb, carreraIn);

		Assert.assertTrue(carreraIn != null && carreraIn.listaCG.isEmpty() == true);
	}

	@Test
	public void parsearCarreraFuturaConPrecioTest() throws Exception {

		String contenidoWeb = resFuturoConSP.getContent("ISO-8859-1");

		CarreraSemillaBetbright carreraIn = new CarreraSemillaBetbright("URL_previa_conocida", null, null, null, null,
				null, new ArrayList<CarreraGalgoSemillaBetbright>());

		BetbrightParserDetalleCarreraFutura.parsear(contenidoWeb, carreraIn);

		Assert.assertTrue(carreraIn != null && !carreraIn.listaCG.isEmpty());
		Assert.assertTrue(carreraIn.listaCG.size() == 6);
		Assert.assertTrue(carreraIn.distancia != null);

		for (CarreraGalgoSemillaBetbright item : carreraIn.listaCG) {
			Assert.assertTrue(item != null);
			Assert.assertTrue(item.galgoNombre != null && !item.galgoNombre.isEmpty());
			Assert.assertTrue(item.precioSp != null);
		}
	}

	@Test
	public void parsearCarreraFuturaConGalgoEliminadoTest() throws Exception {

		String contenidoWeb = resFuturoConGalgoEliminado.getContent("ISO-8859-1");

		CarreraSemillaBetbright carreraIn = new CarreraSemillaBetbright("URL_previa_conocida", null, null, null, null,
				null, new ArrayList<CarreraGalgoSemillaBetbright>());

		BetbrightParserDetalleCarreraFutura.parsear(contenidoWeb, carreraIn);

		Assert.assertTrue(carreraIn != null && !carreraIn.listaCG.isEmpty());
		Assert.assertTrue(carreraIn.listaCG.size() == 5);
		Assert.assertTrue(carreraIn.distancia != null);

		for (CarreraGalgoSemillaBetbright item : carreraIn.listaCG) {
			Assert.assertTrue(item != null);
			Assert.assertTrue(item.galgoNombre != null && !item.galgoNombre.isEmpty());
		}
	}

	@Test
	public void prueba() throws Exception {

		List<CarreraSemillaBetbright> lista = new ArrayList<CarreraSemillaBetbright>();
		for (int i = 0; i < 3; i++) {
			lista.add(new CarreraSemillaBetbright("URL_previa_conocida", null, null, null, null, null,
					new ArrayList<CarreraGalgoSemillaBetbright>()));
			lista.get(i).urlDetalle = "URL" + i;
		}

		for (CarreraSemillaBetbright item : lista) {
			Assert.assertTrue(item != null);
			Assert.assertTrue(item.urlDetalle != null);
			Assert.assertTrue(!item.urlDetalle.isEmpty());
		}
	}

	@After
	public void terminar() {
	}

}