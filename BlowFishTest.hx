import haxe.Timer;
import haxe.io.Bytes;
import haxe.crypto.BlowFish;
import haxe.crypto.mode.Mode;
import haxe.crypto.padding.*;

class BlowFishTest
{
    var keys = [
            "0000000000000000", "FFFFFFFFFFFFFFFF", "3000000000000000", "1111111111111111",
            "0123456789ABCDEF", "1111111111111111", "0000000000000000", "FEDCBA9876543210",
            "7CA110454A1A6E57", "0131D9619DC1376E", "07A1133E4A0B2686", "3849674C2602319E",
            "04B915BA43FEB5B6", "0113B970FD34F2CE", "0170F175468FB5E6", "43297FAD38E373FE",
            "07A7137045DA2A16", "04689104C2FD3B2F", "37D06BB516CB7546", "1F08260D1AC2465E",
            "584023641ABA6176", "025816164629B007", "49793EBC79B3258F", "4FB05E1515AB73A7",
            "49E95D6D4CA229BF", "018310DC409B26D6", "1C587F1C13924FEF", "0101010101010101",
            "1F1F1F1F0E0E0E0E", "E0FEE0FEF1FEF1FE", "0000000000000000", "FFFFFFFFFFFFFFFF",
            "0123456789ABCDEF", "FEDCBA9876543210" 
        ];
    var plainText = [
            "0000000000000000", "FFFFFFFFFFFFFFFF", "1000000000000001", "1111111111111111",
            "1111111111111111", "0123456789ABCDEF", "0000000000000000", "0123456789ABCDEF",
            "01A1D6D039776742", "5CD54CA83DEF57DA", "0248D43806F67172", "51454B582DDF440A",
            "42FD443059577FA2", "059B5E0851CF143A", "0756D8E0774761D2", "762514B829BF486A",
            "3BDD119049372802", "26955F6835AF609A", "164D5E404F275232", "6B056E18759F5CCA",
            "004BD6EF09176062", "480D39006EE762F2", "437540C8698F3CFA", "072D43A077075292",
            "02FE55778117F12A", "1D9D5C5018F728C2", "305532286D6F295A", "0123456789ABCDEF",
            "0123456789ABCDEF", "0123456789ABCDEF", "FFFFFFFFFFFFFFFF", "0000000000000000",
            "0000000000000000", "FFFFFFFFFFFFFFFF"
        ];
    var ecb_ciphers = [
            "4EF997456198DD78", "51866FD5B85ECB8A", "7D856F9A613063F2", "2466DD878B963C9D",
            "61F9C3802281B096", "7D0CC630AFDA1EC7", "4EF997456198DD78", "0ACEAB0FC6A0A28D",
            "59C68245EB05282B", "B1B8CC0B250F09A0", "1730E5778BEA1DA4", "A25E7856CF2651EB",
            "353882B109CE8F1A", "48F4D0884C379918", "432193B78951FC98", "13F04154D69D1AE5",
            "2EEDDA93FFD39C79", "D887E0393C2DA6E3", "5F99D04F5B163969", "4A057A3B24D3977B",
            "452031C1E4FADA8E", "7555AE39F59B87BD", "53C55F9CB49FC019", "7A8E7BFA937E89A3",
            "CF9C5D7A4986ADB5", "D1ABB290658BC778", "55CB3774D13EF201", "FA34EC4847B268B2",
            "A790795108EA3CAE", "C39E072D9FAC631D", "014933E0CDAFF6E4", "F21E9A77B71C49BC",
            "245946885754369A", "6B5C5A9C5D9E0A5A"
        ];

    var ctr_ciphers = [
            "1E162D98E81D4D68", "EC40B68927B90AA7", "1D1A0540DE85CD0F", "949F6A3AB076D8E8",
            "A89CE963A727E931", "2A8B21396B96E91F", "C57CD0F712F988A7", "77C40295491FA71E",
            "F18AC6EDC28B6760", "E57AB70FA1EF4054", "8EBCBCBFFC41D527", "DA7BFE9F1C6E1BB9",
            "9F73CC7A1817B0ED", "8EB961303402986B", "0C0EDEFBF27D487F", "80FDA383E2451234",
            "F11996C46934DF6B", "4CB7BAA10E2D3FB3", "4F0DE906E40A2E7A", "7C2A57EC811EC742",
            "97A2FFD23E5149CC", "AAA7519380E08C6E", "92DC2906FFF763FB", "0D06186639828A63",
            "9450F61AD7E8AC51", "AEBE776E4A256958", "8EDC5FB63C66F8AB", "7260053E520B9688",
            "C0892FF91435C1A4", "CAAFB0AD35C8F302", "0D8BB8F328C41550", "506449BA163197DB",
            "9A22ED8F107143EE", "67B5724A070B3F5A"
        ];
        
    var ctr_iv = [
            "6008498421308702", "B74D803CB412CBA3", "7EEB266C702B32D6", "F280C05F22AF138F",
            "6CBF3B803FA43590", "399BD71F8D08ED20", "65E66760725DEFCC", "4DDE6A6666D37135",
            "49D694D2D320FF5B", "D26FA21A4BCDF9C9", "0CA2FC99021B356C", "64D1F2FAF4EB3B53",
            "1CBE2752611A5759", "44C93114A7F587A2", "74C4B9AFE775629F", "DD59BD9A85A10654",
            "18A6C0CA8210F9CE", "793D5C69408EBF3D", "7FC38460C9225873", "943FACC34BAB0ACC",
            "17A9E725B507CB9E", "9F7F7472D34D8223", "B51343E41B0F92EE", "5FA56F5FD2CEE04F",
            "446EDD035506396F", "FC29CE295B251BF6", "180EBC9498AE3DCE", "E09B89AD1E99E715",
            "73303951A369A8DE", "399E3214799FCF2B", "EB6AB69A94C942B5", "7836AB47BA265104",
            "7CBAC9C2CF26D1BA", "5438ACA317D45230"
        ];

    public function new() 
    {
        trace("Blowfish starts...");
        test_ecb();
        test_ctr();
    }

    public function test(ciphers:Array<String>, cipherMode:Mode, padding:Padding, ivTable:Array<String>):Void
    {
        trace("Starting "+cipherMode+" mode for "+keys.length+" keys");
        var time = Timer.stamp();

        var blowFish : BlowFish = new BlowFish();

        for(i in 0...keys.length)
        {
            var key = Bytes.ofHex(keys[i]);
            var text = Bytes.ofHex(plainText[i]);
            var iv:Bytes = (ivTable == null)?null:Bytes.ofHex(ivTable[i]);
            blowFish.init(key,iv);
            var enc = blowFish.encrypt(cipherMode,text,padding);
            if ( enc.toHex().toUpperCase() != ciphers[i] ) throw "Wrong Blowfish encryption for "+plainText[i]+", expected "+ciphers[i]+" got "+enc.toHex()+" , mode: "+cipherMode;
            var decr = blowFish.decrypt(cipherMode,enc,padding);
            if ( decr.toHex().toUpperCase() != plainText[i] ) throw "Wrong Blowfish decryption for "+enc.toHex()+", expected "+plainText[i]+" got "+decr.toHex()+" , mode: "+cipherMode;
        }

        time = Timer.stamp()-time;
        trace("Finished : "+time+" seconds");
    }

    public function test_ecb():Void
    {
        test(ecb_ciphers,Mode.ECB,Padding.NoPadding,null);
    }

    public function test_ctr():Void
    {
        test(ctr_ciphers,Mode.CTR,Padding.NoPadding,ctr_iv);
    }
}