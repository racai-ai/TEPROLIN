package ro.racai.reterom.tts;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class EntityTest {
    @Test
    public void test() {
        assertEquals("douăzeci și trei", SayEntities.sayNumber("23"));
        assertEquals("patruzeci și cinci virgulă zero trei", SayEntities.sayNumber("45,03"));
        assertEquals("o sută douăzeci și opt virgulă o sută douăzeci și trei",
                SayEntities.sayNumber("128.123"));
        assertEquals("o sută treizeci și unu virgulă doisprezece", SayEntities.sayNumber("131.12"));
        assertEquals("o sută virgulă unu", SayEntities.sayNumber("100.1"));
        assertEquals("zero virgulă o mie patru sute douăzeci și patru",
                SayEntities.sayNumber("0,1424"));
    }
    
    @Test
    public void testBug1() {
        assertEquals("9892013201820232019", SayEntities.sayNumber("9892013201820232019"));
    }
    
    @Test
    public void testBug2() {
        assertEquals("9892013201820232019 virgulă nouă opt nouă doi zero unu trei doi zero unu opt doi zero doi trei doi zero unu nouă", SayEntities.sayNumber("9892013201820232019,9892013201820232019"));
    }
}
