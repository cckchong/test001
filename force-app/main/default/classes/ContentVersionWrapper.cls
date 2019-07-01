/*****************************************************
Content Version Wrapper

1. Get the file type friendly name of each file
2. Get the file icon of each file
******************************************************/
public class ContentVersionWrapper
{
	private Map<String, String> fileTypeMap = new Map<String, String>
	{
		'BMP' => 'Image (BMP)',
		'CSV' => 'Comma Separated Values (CSV)',
		'EXCEL' => 'Excel (XLS)',
		'EXCEL_X' => 'Excel 2007 (XLSX)',
		'EXE' => 'Executable (EXE)',
		'GIF' => 'Image (GIF)',
		'JPG' => 'Image (JPG)',
		'LINK' => 'External Link',
		'MOV' => 'Video (MOV)',
		'WMV' => 'Windows Media',
		'MP4' => 'Video (MP4)',
		'PDF' => 'PDF',
		'PNG' => 'Image (PNG)',
		'POWER_POINT' => 'PowerPoint (PPT)',
		'POWER_POINT_X' => 'PowerPoint 2007 (PPTX)',
		'RTF' => 'Rich Text Format (RTF)', 
		'TEXT' => 'Text',
		'UNKNOWN' => 'Unknown',
		'VISIO' => 'Visio (VSD)',
		'WORD' => 'Word (DOC)',
		'WORD_X' => 'Word 2007 (DOCX)',
		'XML' => 'XML',
		'ZIP' => 'Zip'
	};
    
	private Map<String, String> fileTypeStyleMap = new Map<String, String>
	{
		'BMP' => 'sprite-doctype_image_16',
		'CSV' => 'sprite-doctype_csv_16',
		'EXCEL' => 'sprite-doctype_excel_16',
		'EXCEL_X' => 'sprite-doctype_excel_16',
		'EXE' => 'sprite-doctype_exe_16',
		'GIF' => 'sprite-doctype_image_16',
		'JPG' => 'sprite-doctype_image_16',
		'LINK' => 'sprite-doctype_link_16',
		'MOV' => 'sprite-doctype_video_16',
		'WMV' => 'sprite-doctype_video_16',
		'MP4' => 'sprite-doctype_mp4_16',
		'PDF' => 'sprite-doctype_pdf_16',
		'PNG' => 'sprite-doctype_image_16',
		'POWER_POINT' => 'sprite-doctype_ppt_16',
		'POWER_POINT_X' => 'sprite-doctype_ppt_16',
		'RTF' => 'sprite-doctype_rtf_16',
		'TEXT' => 'sprite-doctype_txt_16',
		'UNKNOWN' => 'sprite-doctype_unknown_16',
		'VISIO' => 'sprite-doctype_visio_16',
		'WORD' => 'sprite-doctype_word_16',
		'WORD_X' => 'sprite-doctype_word_16',
		'XML' => 'sprite-doctype_xml_16',
		'ZIP' => 'sprite-doctype_zip_16'
	};  

	public ContentVersion origContentVersion { get; private set; }
	public String Id
	{
		get
		{
			return origContentVersion.ContentDocumentId;
		}
		private set;
	}
	public String FileName
	{
		get
		{
			return origContentVersion.ContentDocument.Title;
		}
		private set;
	}	
	public String FileType
	{
		get
		{
			return origContentVersion.FileType;
		}
		private set;
	}
	public String TagCsv
	{
		get
		{
			return origContentVersion.TagCsv;
		}
		private set;
	}
	public String friendlyFileType { get; private set; }
	public String fileTypeStyle { get; private set; }		
	public Integer fileSeq{ get; private set; }
		
	public ContentVersionWrapper(ContentVersion CV)
	{
		origContentVersion = CV;
		friendlyFileType = fileTypeMap.get(CV.FileType);
		fileTypeStyle = fileTypeStyleMap.get(CV.FileType);
	}
	
	public ContentVersionWrapper(ContentVersion CV, Integer i)
	{
		origContentVersion = CV;
		fileSeq = i;		
	}
}