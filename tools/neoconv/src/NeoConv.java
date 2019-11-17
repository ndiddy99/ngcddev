public class NeoConv {
    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("Usage: neoconv [-i image.bmp] [-m map.tmx]");
            return;
        }

        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("-i")) {
                Converter converter = new Converter(args[i + 1]);
                converter.writeImage(args[i + 1].substring(0, args[i + 1].indexOf('.')) + ".spr");
                converter.writePalette(args[i + 1].substring(0, args[i + 1].indexOf('.')) + ".pal");
                i++;
            }
            else if (args[i].equals("-m")) {
                String mapStr = args[i+1];
                MapReader mapReader = new MapReader(mapStr);

                mapReader.outputMap(mapStr.substring(mapStr.lastIndexOf('\\') + 1, mapStr.lastIndexOf('.')) + ".map");
                i++;
            }
        }
    }
}
