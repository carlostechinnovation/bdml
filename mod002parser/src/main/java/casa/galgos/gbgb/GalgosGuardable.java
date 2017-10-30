package casa.galgos.gbgb;

public interface GalgosGuardable {

	public String generarSqlCreateTable();

	public String generarDatosParaExportarSql();

	public String generarPath(String pathDirBase);

}
