package CreditCardProcessor;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class PaymentCard {
	public String primaryAccountNumber, iin;
	public String[] track2Fields;

	public PaymentCard(String rawText) throws CardReadException {
			//check error in reading card
			if(rawText.matches("(%|;|\\+)E\\?.*")) {
				throw new CardReadException(null);
			}
			
			track2Fields 		 = getTrack2(rawText).split("=");
			primaryAccountNumber = track2Fields[0];
			// only supporting these Card Issuers as specified here:
			// http://en.wikipedia.org/wiki/List_of_Issuer_Identification_Numbers#Overview
			// hence the length of the substring
			iin = primaryAccountNumber.substring(0, 2);
	}
	
	
	
	/**
	 * @param primaryAccountNumber
	 * @return
	 * Checks if is a luhn number as specified here:
	 * http://en.wikipedia.org/wiki/Luhn_algorithm
	 */
    public boolean isLuhnNumber(){
        int s1 = 0, s2 = 0;
        String reverse = new StringBuffer(primaryAccountNumber).reverse().toString();
        for(int i = 0 ;i < reverse.length();i++){
            int digit = Character.digit(reverse.charAt(i), 10);
            if(i % 2 == 0){//this is for odd digits, they are 1-indexed in the algorithm
                s1 += digit;
            }else{//add 2 * digit for 0-4, add 2 * digit - 9 for 5-9
                s2 += 2 * digit;
                if(digit >= 5){
                    s2 -= 9;
                }
            }
        }
        return (s1 + s2) % 10 == 0;
    }
    
    public boolean isExpired() {
    	// does the card have an expiration date first off
		// determine if card has an expiration date
		boolean hasExpirationDate = track2Fields.length == 2;
		if(!hasExpirationDate) { return false; } // <-- should this be an exception?
		String dateString = track2Fields[1];
			try {
				Date expirationDate = new SimpleDateFormat("yyMM").parse(dateString.substring(0, 4));
	            Calendar cal = Calendar.getInstance();
	            int year = cal.get(Calendar.YEAR);
	            int month = cal.get(Calendar.MONTH);
	            int day = expirationDate.getDate();
	                        
	            Date currentDate = new Date(year-1900, month, day);
	            
	            return (currentDate.compareTo(expirationDate) > 0);
	            
	        } catch (ParseException e) {
	            return false;
	        }
    } 

	private String getTrack2(String cardInput) {
		return cardInput.replaceAll("^(.*);(.*?)\\?(.*)$", "$2");
	}

}