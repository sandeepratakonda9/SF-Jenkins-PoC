@IsTest
private class MyIterableTest {

    @IsTest
    static void testIterableForLoop() {
        // Create a list of strings
        List<String> strings = new List<String>{'Hello', 'World'};

        // Create an instance of MyIterable
        MyIterable myIterable = new MyIterable(strings);

        // Iterate using for loop and print each string
        for (String s : myIterable) {
            System.debug(s);
        }
    }
}