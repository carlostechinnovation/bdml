package casa.galgos.gbgb;

public interface GalgosGuardable {

	public String generarSqlCreateTable(String sufijo);

	public String generarDatosParaExportarSql();

	public String generarPath(String pathDirBase);

}
