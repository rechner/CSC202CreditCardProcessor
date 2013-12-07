/**
 * Container for card issuer information.
 *
 */
public class CardIssuer {
	
	public int id;
	public String name;
	public int PANLength;
	public String IINPrefix;
	public boolean isLuhn;
	public boolean enforceExpiry;
	
	public CardIssuer(int id, String name, int PANLength, String IINPrefix, 
			boolean isLuhn, boolean enforceExpiry) {
		
		this.id = id;
		this.name = name;
		this.PANLength = PANLength;
		this.IINPrefix = IINPrefix;
		this.isLuhn = isLuhn;
		this.enforceExpiry = enforceExpiry;
		
	}

}
