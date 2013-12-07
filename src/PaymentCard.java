import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

class PaymentCard {
	public boolean isExpired, hasExpirationDate, isLuhnNumber;
	public String track2, primaryAccountNumber, iin, expirationDate;
		
	public PaymentCard(String cardInput) {
			track2 = getTrack2(cardInput);
			String[] track2Fields = track2.split("=");
			primaryAccountNumber = track2Fields[0];
			// only supporting these Card Issuers as specified here:
			// http://en.wikipedia.org/wiki/List_of_Issuer_Identification_Numbers#Overview
			iin = primaryAccountNumber.substring(0, 2);
			
			// might not have an expiration date
			if(track2Fields.length == 2) {
				expirationDate = track2Fields[1].substring(0, 4);
				isExpired = isExpiredDate(expirationDate); 
				hasExpirationDate = true;
			} else {
				hasExpirationDate = false;
			}
			
			//check if luhn valid
			// apparently we can have methods and variables named the same
			isLuhnNumber = isLuhnNumber(primaryAccountNumber);
	}
	
	/**
	 * @param number
	 * @return
	 * Checks if is a luhn number as specified here:
	 * http://en.wikipedia.org/wiki/Luhn_algorithm
	 */
    private boolean isLuhnNumber(String number){
        int s1 = 0, s2 = 0;
        String reverse = new StringBuffer(number).reverse().toString();
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
    
	/**
	 * @param cardInput
	 * @return
	 * duhh
	 */
	private String getTrack2(String cardInput) {
		return cardInput.replaceAll("^(.*);(.*?)\\?(.*)$", "$2");
	}

	/**
	 * @param dateString
	 * @return
	 * N.B. dateString *must* be in the form "yyMM"
	 */
	public boolean isExpiredDate(String dateString) {
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
}