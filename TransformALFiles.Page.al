page 50255 "Transform AL Files"
{
    ApplicationArea = All;
    Caption = 'Transform AL Files';
    PageType = List;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(Replacecode)
            {
                ApplicationArea = All;
                Caption = 'Replace Code';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ReplacCode: Codeunit "Transform AL Files";
                begin
                    ReplacCode.Run();
                end;
            }
        }
    }

}
