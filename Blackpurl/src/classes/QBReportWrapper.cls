public without sharing class QBReportWrapper {
    public cls_Header Header;
    public cls_Columns Columns;
    public cls_Rows Rows;
    public class cls_Header {
        public List<cls_ColData> ColData;
    }
    public class cls_Option {
        public String Name;
        public String Value;
    }
    public class cls_Columns {
        public List<cls_Column> Column;
    }
    public class cls_Column {
        public String ColTitle;
        public String ColType;
        public List<cls_MetaData> MetaData;
    }
    public class cls_MetaData {
        public String Name;
        public String Value;
    }
    public class cls_Rows {
        public List<cls_Row> Row;
    }
    public class cls_Row {
        public List<cls_ColData> ColData;
        public String type;
        public cls_Summary Summary;
        public cls_Rows Rows;
    }
    public class cls_ColData {
        public String value;
        public String id;
    }
    public class cls_Summary {
        public List<cls_ColData> ColData;
    }
}