import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class CardParserTest {

	public static void main(String[] args) {
		String cardInput1 = "%B374326224779238^STURGEON/ZACHARY          ^1811121131195622?;374326224779238=121212113119562200000?+1608931216011?";
		String cardInput2 = ";6273660683962088?";

//		System.out.println(getTrack2(cardInput1));
//      System.out.println(getTrack2(cardInput2));
        
        String[] fields = getTrack2(cardInput1).split("=");
		if(fields.length == 2) {
			String expirationDate = fields[1];
			if(isExpiredCard(expirationDate)) {
				//goFuckThyself();
				System.out.println("Is expired");
			}
			else {
				//theWebsiteIsDown();
				System.out.println("Not expired");
			}
		}
	}
	
	public static String getTrack2(String cardInput) {
		// jew witchcraft
        return cardInput.replaceAll("^(.*);(.*?)\\?(.*)$", "$2");
    }
	
	public static boolean isExpiredCard(String dateString) {
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
