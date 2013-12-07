public class Luhn {
    
//	For example, if the trial number is 49927398716:
//
//		Reverse the digits:
//		  61789372994
//		Sum the odd digits:
//		  6 + 7 + 9 + 7 + 9 + 4 = 42 = s1
//		The even digits:
//		    1,  8,  3,  2,  9
//		  Two times each even digit:
//		    2, 16,  6,  4, 18
//		  Sum the digits of each multiplication:
//		    2,  7,  6,  4,  9
//		  Sum the last:
//		    2 + 7 + 6 + 4 + 9 = 28 = s2
//
//		s1 + s2 = 70 which ends in zero which means that 49927398716 passes the Luhn test
	
	public static void main(String[] args) {
        System.out.println(luhnTest("6273660683962088"));
        System.out.println(luhnTest("21448117427928"));
	}
	
    public static boolean luhnTest(String number){
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
}