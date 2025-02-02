SELECT
	ta."Pais" || '|' || ta."Sold" || '|' || ta."CodPos" || '|' || ta."Nombre" || '|' || ta."Direccion" || '|' || 
	ta."RazonSocial" || '|' || ta."Telefono" || '|' || ta."CodAgente" || '|' || ta."NombreAgente" || '|' || ta."NombreProducto"|| '|' ||
	ta."Descripcion" || '|' || ta."CantidadUnidad" || '|' || ta."MontoNeto" || '|' || ta."MontoBruto" || '|' || ta."Costo" || '|' || 
	ta."Fecha" || '|' ||' '|| '|' ||ta."CodZona" || '|' || ta."CodEstado" || '|' || ta."CodCiudad" || '|' || ta."CodBarrio" || '|' || ta."CodTipoPtoVta" || '|' ||
	ta."CedulaJuridica" || '|' || ta."CedulaJuridica" || '|' || ta."ShipTo" || '|' || ta."NombreZona" || '|' ||
	ta."NombreEstado" || '|' || ta."NombreCiudad" || '|' || ta."NombreBarrio" || '|' || ta."NombreTipoPtoVta"
FROM
	(
	SELECT
		'CO' AS "Pais" ,
		'{0}' AS "Sold",
		T1."CardCode" AS "CodPos" ,
		T1."CardName" AS "Nombre" ,
		TO_NVARCHAR(REPLACE(T1."Address", CHAR(13), '')) AS "Direccion" ,
		T5."U_GD_NombComercial" AS "RazonSocial",
		REPLACE(IFNULL(IFNULL(T5."Phone1", IFNULL(T5."Phone2", T5."Cellular")), '0'),'"','') AS "Telefono" ,
		T1."SlpCode" AS "CodAgente" ,
		T11."SlpName" AS "NombreAgente",
		T2."ItemCode" AS "NombreProducto",
		T2."Dscription" AS "Descripcion",
		TO_DECIMAL(CASE 
		WHEN T13."Father" IS NULL THEN t2."Quantity" / T7."SalPackUn" 
		ELSE T2."Quantity" * T13."Quantity" / T14."SalPackUn" 
	END
	) AS "CantidadUnidad",
		CASE
			WHEN T13."Father" IS NULL THEN (T2."LineTotal" - (T2."LineTotal" * T1."DiscPrcnt" / 100))
			ELSE (T2."LineTotal" - (T2."LineTotal" * T1."DiscPrcnt" / 100)) * (T13."Quantity" / P1."Quantity")
		END AS "MontoNeto",
		CASE
			WHEN T13."Father" IS NULL THEN (T2."LineTotal" - (T2."LineTotal" * T1."DiscPrcnt" / 100))
			ELSE (T2."LineTotal" - (T2."LineTotal" * T1."DiscPrcnt" / 100)) * (T13."Quantity" / P1."Quantity")
		END AS "MontoBruto",
		'0' AS "Costo",
		TO_VARCHAR(T1."DocDate", 'DD/MM/YYYY') AS "Fecha" ,
		' ' AS "CodZona" ,
		T5."U_HBT_MunMed" AS "CodEstado" ,
		' ' AS "CodCiudad",
		T5."GroupCode" AS "CodBarrio",
		T5."LicTradNum" AS "CodTipoPtoVta",
		T1."DocNum" AS "CedulaJuridica" ,
		'{1}' AS "ShipTo",
		' ' AS "NombreZona",
		(
		SELECT DISTINCT 
			IFNULL(TD."County", ' ')
		FROM
			{4}.CRD1 TD
		WHERE
			TD."CardCode" = T5."CardCode"
			AND TD."LineNum" = 0) AS "NombreEstado" ,
		(
		SELECT
			IFNULL(TD."City", ' ')
		FROM
			{4}.CRD1 TD
		WHERE
			TD."CardCode" = T5."CardCode"
			AND TD."LineNum" = 0) AS "NombreCiudad" ,
		(
		SELECT
			IFNULL(TD."Block", ' ')
		FROM
			{4}.CRD1 TD
		WHERE
			TD."CardCode" = T5."CardCode"
			AND TD."LineNum" = 0) AS "NombreBarrio" ,
		T6."GroupName" AS "NombreTipoPtoVta"
		--	DOCUMENTO
	FROM
		{4}."OINV" T1
	INNER JOIN
	{4}."INV1" T2
		ON
		T1."DocEntry" = T2."DocEntry"
	INNER JOIN
	{4}."INV12" T3
		ON
		T1."DocEntry" = T3."DocEntry"
	INNER JOIN
	{4}."NNM1" T4
		ON
		T1."Series" = T4."Series"
		--	CLIENTE
	INNER JOIN
	{4}."OCRD" T5
		ON
		T1."CardCode" = T5."CardCode"
		--LEFT JOIN CRD1 TD ON TD."CardCode" = T5."CardCode" 
	INNER JOIN
	{4}."OCRG" T6
		ON
		T5."GroupCode" = T6."GroupCode"
		--	PRODUCTO
	INNER JOIN
	{4}."OITM" T7
		ON
		T2."ItemCode" = T7."ItemCode"
	INNER JOIN
	{4}."OITB" T8
		ON
		T7."ItmsGrpCod" = T8."ItmsGrpCod"
	LEFT JOIN
	{4}."@GD_SUBGRUPO" T9
		ON
		T7."U_GD_SubGrupo" = T9."Code"
	LEFT JOIN
	{4}."@GD_FAMPRODUCTOS" T10
		ON
		T7."U_GD_FamProducto" = T10."Code"
		--	VENDEDOR
	INNER JOIN
	{4}."OSLP" T11
		ON
		T1."SlpCode" = T11."SlpCode"
		--Generar Desagregado de combos
	LEFT JOIN {4}.ITT1 T13 ON
		T7."ItemCode" = T13."Father"
	LEFT JOIN {4}.OITM T14 ON
		T13."Code" = T14."ItemCode"
	LEFT JOIN (
		SELECT
			TA."Father",
				sum(TA."Quantity")AS "Quantity"
		FROM
			{4}.ITT1 TA
		INNER JOIN {4}.OITM TB ON
			TA."Code" = TB."ItemCode"
		GROUP BY
			TA."Father")AS P1 ON
		T7."ItemCode" = P1."Father"
	WHERE
		T1."DocDate" BETWEEN '{5}' AND '{6}'
		--T1."DocDate" BETWEEN '20221101' AND '20221130'
		--T1."DocDate" BETWEEN ADD_DAYS(LAST_DAY(ADD_MONTHS(CURRENT_DATE, -1)),+1) AND ADD_DAYS(TO_VARCHAR(CURRENT_DATE,'YYYYMMDD'), -1 )
		AND T8."ItmsGrpCod" = {2}
		--	Buscar por códigos
		AND T2."WhsCode" IN ({3})
UNION ALL
	SELECT 
		'CO' AS "Pais" ,
		'{0}' AS "Sold",
		T1."CardCode" AS "CodPos" ,
		T1."CardName" AS "Nombre" ,
		TO_NVARCHAR(REPLACE(T1."Address", CHAR(13), '')) AS "Direccion" ,
		T5."U_GD_NombComercial" AS "RazonSocial",
		REPLACE(IFNULL(IFNULL(T5."Phone1", IFNULL(T5."Phone2", T5."Cellular")), '0'),'"','') AS "Telefono" ,
		T1."SlpCode" AS "CodAgente" ,
		T11."SlpName" AS "NombreAgente",
		T2."ItemCode" AS "NombreProducto",
		T2."Dscription" AS "NombreProducto",
		TO_DECIMAL(CASE 
		WHEN T13."Father" IS NULL THEN t2."Quantity" / T7."SalPackUn" 
		ELSE T2."Quantity" * T13."Quantity" / T14."SalPackUn" 
	END
	) AS "CantidadUnidad",
		CASE
			WHEN T13."Father" IS NULL THEN -(T2."LineTotal" - (T2."LineTotal" * T1."DiscPrcnt" / 100))
			ELSE -(T2."LineTotal" - (T2."LineTotal" * T1."DiscPrcnt" / 100)) * (T13."Quantity" / P1."Quantity")
		END AS "MontoNeto",
		CASE
			WHEN T13."Father" IS NULL THEN -(T2."LineTotal" - (T2."LineTotal" * T1."DiscPrcnt" / 100))
			ELSE -(T2."LineTotal" - (T2."LineTotal" * T1."DiscPrcnt" / 100)) * (T13."Quantity" / P1."Quantity")
		END AS "MontoBruto",
		' ' AS "Costo",
		TO_VARCHAR(T1."DocDate", 'DD/MM/YYYY') AS "Fecha" ,
		' ' AS "CodZona" ,
		T5."U_HBT_MunMed" AS "CodEstado" ,
		' ' AS "CodCiudad",
		T5."GroupCode" AS "CodBarrio",
		T5."LicTradNum" AS "CodTipoPtoVta",
		T1."DocNum" AS "CedulaJuridica" ,
		'{1}' AS "ShipTo",
		' ' AS "NombreZona",
		(
		SELECT
			IFNULL(TD."County", ' ')
		FROM
			{4}.CRD1 TD
		WHERE
			TD."CardCode" = T5."CardCode"
			AND TD."LineNum" = 0) AS "NombreEstado" ,
		(
		SELECT
			IFNULL(TD."City", ' ')
		FROM
			{4}.CRD1 TD
		WHERE
			TD."CardCode" = T5."CardCode"
			AND TD."LineNum" = 0) AS "NombreCiudad" ,
		(
		SELECT
			IFNULL(TD."Block", ' ')
		FROM
			{4}.CRD1 TD
		WHERE
			TD."CardCode" = T5."CardCode" 
			AND TD."LineNum" = 0) AS "NombreBarrio" ,
		T6."GroupName" AS "NombreTipoPtoVta"
		--	DOCUMENTO
	FROM
		{4}."ORIN" T1
	INNER JOIN
	{4}."RIN1" T2
		ON
		T1."DocEntry" = T2."DocEntry"
	INNER JOIN
	{4}."RIN12" T3
		ON
		T1."DocEntry" = T3."DocEntry"
	INNER JOIN
	{4}."NNM1" T4
		ON
		T1."Series" = T4."Series"
		--	CLIENTE
	INNER JOIN
	{4}."OCRD" T5
		ON
		T1."CardCode" = T5."CardCode"
	INNER JOIN
	{4}."OCRG" T6
		ON
		T5."GroupCode" = T6."GroupCode"
		--	PRODUCTO
	INNER JOIN
	{4}."OITM" T7
		ON
		T2."ItemCode" = T7."ItemCode"
	INNER JOIN
	{4}."OITB" T8
		ON
		T7."ItmsGrpCod" = T8."ItmsGrpCod"
	LEFT JOIN
	{4}."@GD_SUBGRUPO" T9
		ON
		T7."U_GD_SubGrupo" = T9."Code"
	LEFT JOIN
	{4}."@GD_FAMPRODUCTOS" T10
		ON
		T7."U_GD_FamProducto" = T10."Code"
		--	VENDEDOR
	INNER JOIN
	{4}."OSLP" T11
		ON
		T1."SlpCode" = T11."SlpCode"
		--Generar Desagregado de combos
	LEFT JOIN {4}.ITT1 T13 ON
		T7."ItemCode" = T13."Father"
	LEFT JOIN {4}.OITM T14 ON
		T13."Code" = T14."ItemCode"
	LEFT JOIN (
		SELECT
			TA."Father",
				sum(TA."Quantity")AS "Quantity"
		FROM
			{4}.ITT1 TA
		INNER JOIN {4}.OITM TB ON
			TA."Code" = TB."ItemCode"
		GROUP BY
			TA."Father")AS P1 ON
		T7."ItemCode" = P1."Father"
	WHERE
		T1."DocDate" BETWEEN '{5}' AND '{6}'
		AND T8."ItmsGrpCod" = {2}
		--	Buscar por códigos
		AND T2."WhsCode" IN ({3}) ) ta