import static net.sourceforge.jwebunit.junit.JWebUnit.*;

import org.junit.Before;
import org.junit.Test;

public class JUnitTestMainProxy {
	
    @Before
    public void prepare() {
        setBaseUrl("http://profox.crabdance.com:8080/CreditCardProcessor");
    }

    @Test
    public void testVirtualTerminal() {
        beginAt("virtualterminal.jsp"); //Open the browser on http://localhost:8080/test/home.xhtml
        setTextField("amount", "100.00");
        setTextField("ccn", ";6273660683962088?");
        submit();
        assertButtonPresent("checkOut");
    }
    @Test
    public void testBalanceInquiry() {
    	beginAt("check-balance.jsp");
    	setTextField("ccn", ";6273660683962088?");
        submit();
    	assertTextPresent("Remaining balance for");
    }
    
    @Test
    public void testDeposit() {
    	beginAt("deposit.jsp");
    	setTextField("ccn", ";6273660683962088?");
    	setTextField("amount", "100.00");
        submit();
    	assertTextPresent("The funds were deposited successfully.");
    }
    
   @Test
   public void testCardNotPresentInBalance() {
	   	beginAt("check-balance.jsp");
	   	setTextField("ccn", "%B4290019297311319^STURGEON/ZACHARY W.       ^1108101000000014976000000000002?");
	    submit();
	   	assertTextPresent("Card issuer not the database.");
   }
   
   @Test
  public void testCardHolderNotInDatabaseInBalance() {
	   	beginAt("check-balance.jsp");
	   	setTextField("ccn", "628900192973113");
	    submit();
	   	assertTextPresent("Cardholder not in database");
  }
   
    
   @Test
   public void testCardNotPresentInVirtualTerminal() {
	   	beginAt("virtualterminal.jsp");
        setTextField("amount", "100.00");
	   	setTextField("ccn", "%B4290019297311319^STURGEON/ZACHARY W.       ^1108101000000014976000000000002?");
	    submit();
	   	assertTextPresent("Card issuer not the database.");
   }
    
   @Test 
   public void testCardIssuerAlreadyPresent() {
	   beginAt("add-issuer.jsp");
	   setTextField("name", "Nova Card");
	   setTextField("iin", "62");
	   submit();
	   assertTextPresent("A card issuer with the same IIN already exists");
   }
   
}