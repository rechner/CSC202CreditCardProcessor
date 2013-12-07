import java.io.File;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import com.almworks.sqlite4java.*;


public class PaymentGateway {
	
	public SQLiteConnection db = null;
	
	public PaymentGateway(String databaseFile) {
		
		db = new SQLiteConnection(new File(databaseFile));
		try {
			db.open(true);
			this.CreateTables();
		} catch (SQLiteException e) {
			e.printStackTrace();
		}
		
	}
	
	/**
	 * Initialises an empty database.
	 * @throws SQLiteException
	 */
	private void CreateTables() throws SQLiteException {
		
		SQLiteStatement st;
		try {
			st = db.prepare("SELECT name FROM merchant;");
			while(st.step());
			st.dispose();
		
		} catch (SQLiteException e) {
			// the table we queried probably doesn't exist. Create tables:
			
			// gateway table
			st = db.prepare("CREATE TABLE `gateway` (id INTEGER PRIMARY KEY,"
					+ "	issuer TEXT NOT NULL, length INT DEFAULT 16 NOT NULL,"
					+ "	iin_number TEXT NOT NULL, luhn_validation BOOLEAN "
					+ "DEFAULT TRUE NOT NULL, enforce_expiry BOOLEAN DEFAULT "
					+ "FALSE NOT NULL);");
			while (st.step());
			st.dispose();
			
			//transactions table
			st = db.prepare("CREATE TABLE `transactions` (id INTEGER PRIMARY KEY,"
					+ "	issuer_id INTEGER, FOREIGN KEY(issuer_id) REFERENCES gateway(id),"
					+ "	account_number TEXT NOT NULL, ammount REAL NOT NULL,"
					+ "	timestamp DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,"
					+ "	settled BOOLEAN DEFAULT NULL, merchant INTEGER,"
					+ "	FOREIGN KEY(merchant) REFERENCES merchant(id));");
			while (st.step());
			st.dispose();
			
			//merchant table
			st = db.prepare("CREATE TABLE `merchant` (id INTEGER PRIMARY KEY,"
					+ " balance REAL NOT NULL DEFAULT 0, name TEXT);");
			while (st.step());
			st.dispose();
			
		}
				
	}
	
	/**
	 * Adds a card issuer to the system.
	 * 
	 * @param issuerName String identifying the issuer belonging to this record
	 * @param PANLength int Length of the personal account number (PAN).  Usually 16 digits.
	 * @param iin_number Two digit string identifying the issuing organization.  Prefix for PAN.
	 * @param isLuhn Set to true if account numbers should be checked with the Luhn algorithm.
	 * @return
	 * 
	 */
	public void AddCardIssuer(String issuerName, int PANLength, 
		String iin_number, boolean isLuhn, boolean enforceExpiry) 
				throws PaymentGatewayException {
		
		// insert issuer row into `gateway`:
		SQLiteStatement st;
		
		try {
			
			st = db.prepare("INSERT INTO gateway(issuer, length, iin_number, luhn_validation,"
					+ " enforce_expiry) VALUES (?, ?, ?, ?, ?);");
			st.bind(0,  issuerName);
			st.bind(1, PANLength);
			st.bind(2, iin_number);
			st.bind(3, (isLuhn ? 1 : 0));
			st.bind(4, (enforceExpiry ? 1: 0));
			while (st.step());
			st.dispose();
			
			// Add the supporting tables:
			this.AddCardIssuerAccountTable(issuerName, PANLength);
			
		} catch (SQLiteException e) {
			throw new PaymentGatewayException("Unable to add card issuer to database: " + e.getMessage(), e);		
		}
		
	}
	
	
	/**
	 * Adds the supporting table for a card issuer, to contain all of the issuer 
	 * customer accounts and information.
	 * @param issuerName String issuer name (e.g. "Discover", "Visa").
	 * @param PANLength integer length that personal account numbers should be (usually 16).
	 * @throws PaymentGatewayException 
	 */
	private void AddCardIssuerAccountTable(String issuerName, int PANLength) 
			throws PaymentGatewayException {
		
		SQLiteStatement st;
		
		try {
			
			st = db.prepare("CREATE TABLE debit_? id INTEGER PRIMARY KEY,"
					+ " account_number TEXT NOT NULL CHECK (LENGTH(account_number) = ?),"
					+ "	balance REAL CHECK (balance >= 0) DEFAULT 0,"
					+ "	name TEXT NOT NULL);");
			
			st.bind(0, issuerName);
			st.bind(1, PANLength);
			while(st.step());
			st.dispose();			
			
		} catch (SQLiteException e) {
			throw new PaymentGatewayException("Unable to add card issuer to database: " + e.getMessage(), e);
		}
	}

}


