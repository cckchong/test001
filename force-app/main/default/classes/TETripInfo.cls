public class TETripInfo {
    
    public String itineraryDate{get; set;}
    public Integer itineraryYear{get; set;}
    public Date fromDate{get; set;}
    public String fromCity{get; set;}
    public String fromTerminal{get; set;}
    public String fromTime{get; set;}
        
    public Date toDate{get; set;}
    public String toCity{get; set;}
    public String toTerminal{get; set;}
    public String toTime{get; set;}
    
    public String flightClass{get; set;}
    public String status{get; set;}
    public Boolean stop{get; set;}
    public String eqp{get; set;}
    public String flyingTime{get; set;}
    public String sevices{get; set;}
    public Boolean isSkip{get; set;}
    
    Public Map<String, Integer> monthMap{get; set;}
    public String split{get; set;}
    public String content{get; set;}    
    public String Flight{get; set;}
    
    public TETripInfo ( String itineraryDate, String content, String split){
        monthMap = new Map<String, Integer>();
        this.content = content;
        this.itineraryDate = itineraryDate;
        this.itineraryYear = Integer.valueOf(itineraryDate.substring( itineraryDate.length()-4, itineraryDate.length()));
        this.split = split;
        this.isSkip = false;
        monthMap = monthMapSetting(monthMap);
        retrieveTripData(this.content);
    }
    
    public void retrieveTripData( String content ){
        String dateString = '';
        Integer counter = 1;
        for ( String reader : content.split(split) ){
            try{
                if ( counter == 1 ){
                    if ( reader.length() > 0 ){                    
                        dateString = reader.substring(5,10) + String.valueof(this.itineraryYear);
                        if ( monthMap.get(reader.substring(7,10)) < monthMap.get(itineraryDate.substring(0,3)) ){
                            dateString = reader.substring(5,10) + String.valueof(this.itineraryYear+1);
                        }
                        this.fromDate = Date.newInstance(Integer.valueof(dateString.substring(5,9)), monthMap.get(dateString.substring(2,5).toUpperCase()), Integer.valueof(dateString.substring(0,2)) );
                        this.toDate = this.fromDate ;
                        this.fromCity = reader.substring(16,39);
                        this.fromTime = reader.substring(39,43);
                        this.Flight = reader.substring(47,65);
                        if ( reader.substring(65,68) == 'NON' ){
                            this.stop = false;
                        }
                        else{
                            this.stop = true;
                        }
                    }
                }
                
                if ( counter == 2 ){
                    if ( reader.length() > 0 ){
                        this.fromTerminal = reader.substring(16,47);
                        this.flightClass = reader.substring(47,65);
                        this.eqp  = reader.substring(65, reader.length());
                    }
                }
                
                if ( counter == 3 ){
                    if ( reader.length() > 0 ){
                        if ( reader.substring(5,10).replaceall('[ ]','') != '' ){
                            dateString = reader.substring(5,10) + String.valueof(this.itineraryYear);
                            if ( monthMap.get(reader.substring(7,10)) < monthMap.get(itineraryDate.substring(0,3)) ){
                                dateString = reader.substring(5,10) + String.valueof(this.itineraryYear+1);
                            }
                            this.toDate = Date.newInstance(Integer.valueof(dateString.substring(5,9)), monthMap.get(dateString.substring(2,5).toUpperCase()), Integer.valueof(dateString.substring(0,2)) );
                            //dateString
                            //this.toDate= reader.substring(5,10);
                            
                        }
                        this.toCity = reader.substring(16,39);
                        this.toTime = reader.substring(39,43);
                        this.status = reader.substring(47,65);
                        this.flyingTime = reader.substring(65, reader.length());
                    }
                }
                if ( counter == 4 ){
                    if ( reader.length() > 0 ){
                        this.toTerminal = reader.substring(16,reader.length());
                    }
                }            
                counter += 1;
            } 
            catch(Exception e){
                this.isSkip = true;
                break;
            }
        }
    }
    
    
    public Map<String, Integer> monthMapSetting( Map<String, Integer> month){        
        month.put('JAN' , 1);
        month.put('FEB' , 2);
        month.put('MAR' , 3);
        month.put('APR' , 4);
        month.put('MAY' , 5);
        month.put('JUN' , 6);
        month.put('JUL' , 7);
        month.put('AUG' , 8);
        month.put('SEP' , 9);
        month.put('OCT' , 10);
        month.put('NOV' , 11);
        month.put('DEC' , 12);
        return month;
    }
    
}