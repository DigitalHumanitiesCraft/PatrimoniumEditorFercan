<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<!-- --> 
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- add <link> based on <app>; target="#MAJ.1 #MIN.1" -->
	<xsl:template match="*:TEI/*:text/*:body/*:linkGrp">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:for-each select="//*:div[@subtype='diplomatic'][@type='edition']/*:ab/*:orig/*:lb">
				<link target="{concat('#MAJ.', position(), ' #MIN.', position())}"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
	<!-- remove all idno with " " or empty -->
	<xsl:template match="//*:idno[not(text()) or text() = ' ']"/>

	<!-- fix @xml:id in bibliography; adding "LIT." -->
	<xsl:template match="*:TEI/*:text/*:body/*:div[@type='bibliography'][@subtype='editions']/*:listBibl/*:bibl">
		<bibl xml:id="{normalize-space(@xml:id)}">
			<xsl:apply-templates/>
		</bibl>
	</xsl:template>
	
	<xsl:template match="*:TEI/*:text/*:body/*:div[@xml:id='majuscule']/*:ab[not(*:orig)]">
		<xsl:copy>
			<orig>
				<xsl:apply-templates/>
			</orig>
		</xsl:copy>
	</xsl:template>
	
	<!-- lb xml:id MIN. -->
	<xsl:template match="*:TEI/*:text/*:body/*:div[@xml:id='minuscule']/*:ab/*:lb">
		<lb n="{@n}" xml:id="{concat('MIN.', @n)}"/>
	</xsl:template>
	
	<!-- lb xml:id MAJ. -->
	<xsl:template match="*:TEI/*:text/*:body/*:div[@xml:id='majuscule']/*:ab/*:lb">
		<lb n="{@n}" xml:id="{concat('MAJ.', @n)}"/>
	</xsl:template>
	
	<xsl:template match="*:i"/>
	
	<!-- skip all Editors's comments in back/note -->
	<xsl:template match="*:back"/>
	
	<!-- remove if empty -->
	<xsl:template match="@notBefore"/>
	<xsl:template match="@notAfter"/>
	
	<!-- fix <p> in <p> -->
	<xsl:template match="*:p/*:p"><xsl:apply-templates/></xsl:template>
	
	<!-- remove all comments -->
	<xsl:template match="comment()"/>
	
	<!-- replace <br/>  -->
	<xsl:template match="*:br">
		<lb/>
	</xsl:template>
	
	<!-- add <p> because of textarea generated <br> from editor; fix on webpage?  -->
	<xsl:template match="/*:TEI/*:teiHeader/*:fileDesc/*:sourceDesc/*:msDesc/*:history/*:provenance">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:choose>
				<xsl:when test="*:p">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<p>
						<xsl:apply-templates/>
					</p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<!--  add context target; ";" seperation-->
	<xsl:template match="*:ref[@type='context']">
		<xsl:choose>
			<xsl:when test="contains(text(), ';')">
				<xsl:variable name="ana" select="@ana"/>
				<xsl:variable name="target" select="@target"/>
				<xsl:for-each select="tokenize(text(), ';')">
					<ref type="context" target="{concat($target, translate(lower-case(normalize-space(.)), ' ', '') )}">
						<xsl:if test="$ana">
							<xsl:attribute name="ana" select="$ana"/>
						</xsl:if>
						<xsl:value-of select="normalize-space(.)"/>
					</ref>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<ref type="context" target="{concat( @target, translate(lower-case(normalize-space(text())), ' ', '') )}">
					<xsl:if test="@ana">
						<xsl:attribute name="ana" select="@ana"/>
					</xsl:if>
					<xsl:value-of select="normalize-space(.)"/>
				</ref>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- skip all nodes that dont have text or just " " and have no attributes and of no childs and are not <lb> -->
	<xsl:template match="*[not(text()) or text() = ' '][not(@*)][not(*)][not(local-name()= 'lb')]"/>
	
	<!-- add <ref type="context" target="context:fercan.arch.fragment">Fragment</ref> -->
	<xsl:template match="/*:TEI/*:teiHeader/*:fileDesc/*:sourceDesc/*:msDesc/*:physDesc/*:decoDesc/*:decoNote/*:term">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ref type="context" target="{concat( 'context:fercan.arch.', translate(lower-case(*:ref/text()), ' ', '') )}">
				<xsl:apply-templates/>	
			</ref>
		</xsl:copy>
	</xsl:template>
	
	<!--  -->
	<xsl:template match="/*:TEI/*:teiHeader/*:fileDesc/*:sourceDesc/*:msDesc/*:history/*:provenance/*:location/*:geo">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:text>ToDo: add coordinates</xsl:text>
		</xsl:copy>
	</xsl:template>
	
	<!-- skip nasty attributes from schema -->
	<xsl:template match="@instant"/>
	<xsl:template match="@default"/>
	<xsl:template match="@full"/>
	<xsl:template match="@status"/>
	<xsl:template match="@part"/>
	<xsl:template match="@anchored"/>
	<xsl:template match="@sample"/>
	<xsl:template match="@org"/>
	<xsl:template match="@lang"/>
	
	
</xsl:stylesheet>