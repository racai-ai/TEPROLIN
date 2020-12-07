package ro.racai.reterom.tts;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class EntityTest {
    @Test
    public void test() {
        assertEquals("douăzeci și trei", SayEntities.sayNumber("23"));
        assertEquals("patruzeci și cinci virgulă zero trei", SayEntities.sayNumber("45,03"));
        assertEquals("o sută douăzeci și opt virgulă unu doi trei", SayEntities.sayNumber("128.123"));
    }
}
