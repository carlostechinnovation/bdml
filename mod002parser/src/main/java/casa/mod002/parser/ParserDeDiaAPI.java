package casa.mod002.parser;

public interface ParserDeDiaAPI {

	/**
	 * @param in
	 * @return
	 */
	public String parsear(String tagDia, String in);

	/**
	 * @return
	 */
	public String getPathEntrada(String tagDia);

	public String generarSqlCreateTable();

}