import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:test_app/src/rust/api/openai/chat.dart';
import 'msg.dart';

class Chat extends StatefulWidget {
  const Chat({ super.key });

  @override
  State<Chat> createState() => _Chat();
}

class _Chat extends State<Chat> {
    
  final TextEditingController _controller = TextEditingController();  // Controller for TextField
  String chatLog = "";
  bool api = true;
  String apiKeys = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: HexColor('000000')
              ),
              child: GroupedListView<Message, DateTime>(
                padding: const EdgeInsets.all(10),
                elements: messages,
                groupBy: (message) => DateTime(2024),
                groupHeaderBuilder: (Message message) => const SizedBox(),
                itemBuilder: (context, Message message) => Align(
                  alignment: message.isSentByMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                  child: Card(
                    color: message.isSentByMe
                      ? HexColor('#00000')
                      : HexColor('#00000'),
                    margin: message.isSentByMe
                      ? const EdgeInsets.only(left: 42, top: 10, bottom: 10, right: 10)
                      : const EdgeInsets.only(right: 20, top: 10, bottom: 10, left: 10),
                    elevation:10,
                    child: Container(
                      decoration: BoxDecoration(
                        border: message.isSentByMe 
                          ? Border(
                            right: BorderSide(
                              color: message.isSentByMe
                                ? Colors.blueAccent 
                                : Colors.amberAccent,
                              width: 1 
                            )
                            )
                          : Border(
                            left: BorderSide(
                              color: message.isSentByMe
                                ? Colors.black 
                                : Colors.grey,
                              width: 1 
                            )
                          ),
                      ),
                      padding: const EdgeInsets.all(13),
                      child: MarkdownBody(
                        selectable: true,
                        styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            ThemeData(
                              textTheme: TextTheme(
                                bodyMedium: TextStyle(
                                  fontSize: 14,
                                  fontWeight: message.isSentByMe
                                    ? FontWeight.w300
                                    : FontWeight.w200,
                                  color: message.isSentByMe
                                    ? HexColor('#EEEEEE')
                                    : HexColor('#EEEEEE'),
                                )
                              ) 
                            ),
                        ).copyWith(
                          codeblockDecoration: 
                            BoxDecoration (
                              border: Border.all(
                                color: Colors.white24,
                                width: 0.5
                              ),
                              borderRadius: BorderRadius.circular(10)
                            ),
                          code: TextStyle (
                              fontSize: 12,
                              color: Colors.blueAccent,
                          ),
                          h1: TextStyle(color: HexColor('#EEEEEE')), 
                          h2: TextStyle(color: HexColor('#EEEEEE')), 
                          h3: TextStyle(color: HexColor('#EEEEEE')), 
                        ),
                        data: message.text,
                        builders: {
                          'latex' : LatexElementBuilder(
                            textStyle: TextStyle(color: Colors.blueAccent),
                          ),
                        },
                        extensionSet: md.ExtensionSet(
                        [
                          ...[LatexBlockSyntax()],
                          ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                        ],
                        [
                          ...<md.InlineSyntax>[
                            md.EmojiSyntax(),
                            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                          ],
                        ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: HexColor('#000000'),
            child: Container(
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: HexColor('#EEEEEE'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  hintText: "Hva tenker du på?",
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                onSubmitted: (text)  async{   
                  _controller.clear();
                  chatHistories.add(("user", text));
                  String response = await chat(input: chatHistories );
                  chatHistories.add(("assistant", response));
                  setState(() {
                    messages.add(
                      Message(
                        text: text, 
                        isSentByMe: true,
                      ),
                    );
                    messages.add(
                      Message(
                        text: response,
                        isSentByMe: false,
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

AppBar appBar() {
  return AppBar(
    title: const Text(
      "Merge AI",
      style: TextStyle(
        color: Colors.amberAccent,
        fontSize: 18,
        fontWeight: FontWeight.w800
      ),
    ),
    elevation: 0,
    centerTitle: false,
    backgroundColor: HexColor('#000000'),
    leading: GestureDetector(
      onTap: () {
        
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: SvgPicture.asset('assets/icons/stack.svg'),
        decoration: BoxDecoration(
          color: Colors.amberAccent,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    ),
  );
}
