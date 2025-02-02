SELECT 
CONCAT( TA.item,'{',TA.NameItem,'{RG{',TA.salpack,'{',TA.item,'{',TA.CodeG,'{A') 
from(
select
(replace(CONVERT(varchar, getdate(), 11), '/', '')) as EndDate,  + REPLACE(REPLACE(RTRIM(REPLACE(RTRIM(LTRIM(ISNULL(CAST(ArtFicTec AS VARCHAR(249)), ''))), '', '')), CHAR(13), ''), CHAR(10), '') as item ,
	convert( int,
	isnull((
SELECT
		sum(CASE WHEN karnat = '+' THEN (karuni +(KARCAJ * KARARTEMB)) WHEN karnat = '-' THEN (karuni +(KARCAJ * KARARTEMB))* -1 END)
	FROM
		kardex K
	LEFT JOIN Factura f ON
		f.FacSec = k.FacSec
	WHERE
	f.FacFec BETWEEN '20200101' and '20230831'
		AND k.SubBodSucCCSec = 2
		and f.facest = 'A'
		and artsec = a.artsec
	group by
		artsec),
	0) ) as quanty,
	(
	SELECT
		TOP 1 PREARTNOM
	FROM
		ArtPre AA
	LEFT JOIN PresentacionArticulos PA ON
		AA.preartcod = PA.preartcod
	WHERE
		AA.ARTSEC = A.ARTSEC) as salpack, a.ArtCod  as coded,
	a.ArtNom as NameItem,
	SS.InvGruCod as CodeG
from
	Articulos a
LEFT JOIN InventarioFamilia FF ON
	FF.InvFamCod = A.InvFamCod
LEFT JOIN InventarioSubgrupo SS ON
	SS.InvSubGruCod = FF.InvSubGruCod
where
	InvGruCod IN('3') ) as TA

GROUP by TA.item, TA.salpack, TA.NameItem, TA.CodeG


    