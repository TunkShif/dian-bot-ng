defmodule Dian.Accounts.UserNotifier do
  import Swoosh.Email

  alias Dian.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"LITTLE RED BOOK", "little.red.book@tunkshif.one"})
      |> subject(subject)
      |> html_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to register account.
  """
  def deliver_registration_instructions(email, url) do
    title = "[LITTLE RED BOOK] 注册申请确认"
    template = render_registration_email_fallback(url)
    deliver(email, title, template)
  end

  defp render_registration_email(url) do
    attrs = Phoenix.HTML.attributes_escape(href: url) |> Phoenix.HTML.safe_to_string()

    mjml =
      """
      <mjml>
        <mj-head>
          <mj-font name="Inter" href="https://fonts.loli.net/css?family=Inter" />
          <mj-font name="Silkscreen" href="https://fonts.loli.net/css?family=Silkscreen" />
          <mj-attributes>
            <mj-all font-family="Inter" />
          </mj-attributes>
        </mj-head>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-image width="180px" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOsAAAAjCAYAAAB1sf0MAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAASKSURBVHgB7Z1PaNRAFMbfrC1WT3sq4ipuwYMWkR7EcxSPIj1ZV0FbFI+23hQUFQTFU/UoSrcHafViEY9i06t46KH45+SCroinPYgobTNOZnfaZDrJJtmk3eD3g/A6Sd5Msplk5s03SYkAAAAAAAAAAIDuhJlWXuo9yF175aoj0zsPDUp7/+InSsK1pwek/b30QdrDDz4zAgDEokAAgFzga+FUi3qif5dMH7lXlPb99Qalgcpv//mXaFkBiAlaVgByQk/YRhWjqpa2U5LGvAAAtKwA5IYe6mJm9liWMJZKV77ZtyP4ePexhY/9fK817HAaaufLODXO1O3JqbJV7FuhCYrANk5zp+v2orcMlU+Y30zZKtMKjVIUVqha+WHXouw6U7JGxUhEud1+BU5fRur2tL5+tmRNcEbFdv7cocWz3+25FyVraJXRMEXgzy+aHGvYsQdA9HoQRoI6krl/1Lqh1ztVt1Q60c2qBoqUFKOkHZ0UBqYsxtktT/p2Owfv/pzJ8TLbcWiYEbtA7amJZbLvDxXZNl+5gawSd30WtTJkPqGOK1TWzi0Q3sPtVp5tkcfA21dsIcotCDO9sTA2Lkb/yu38GeNVYeZWiYainkdfUfg0KEmlsKKWQTHryGb4R60ber1TdUul0Q0GICckalnXW8zdLZuOtAMACKarY9a0qNTtUWHchWZ2WWXR1fiitnHiY2J71bd/Mz5c04JFHFj1dmPO1OcHKGVEl/2YG19TioggYKFSn7dM29zYdrZ0jIeXz6sivhqjOGX28oFKzRxfu+WJJXHeCvH7G3V699pq53THjSHdGNMXHoljDMo7C38KwVC3AucgJLpZB899l1bFqkGxa1qTKQBIk6CHicv6wyQ7/6QgZgUgJyRqWT8802NVxK6dIgauL7Qkio3EkG58eRLtC5IZOBfyjOimecqobfRnQ4H+LemGtoDAYyIxmsqpqxHXpKgdf02EYvI6uLJOmO9/EbPmAzYaVNHiSDcaYfLQQuWbOZ5dK7cpyxj1aSXd0BYQdE55mHDefKB44l/DmEkQ6AYDkBNwswKQE9AN7hI2Q7oRI5XzFHHaXiuHxPJKloRJN15ZrkvxSX+udCOuy5Rpm07ozaq+8AAJBoCtB91gAHKCsWV98/OHtINLzckPR+519g0mhfqm05MHlIhO35bYLAzD8+vbAt66yEK60REjj9Pi4BZU2neMhjKSSDd8uTAhfIxdMYezh4w5DeVPCQmTbog8chSRrSz3DLXPlqypgKzlrKMM/AMpFGjO4XLCvsR7bqm8dbNVdPq2xGahD89r1Mj41kUm0o0Pr0TgPhjEMc6HlZFEuikQHxc1loz0OgNhs3+iEibdmOLZ1liArdLeKYEb903fP4yRr/KBJ39HPebW37ox3qyP3z3ypV+cvCvtif5+3/rTr29QHC4fvUIAgGQgZgUgJxi/bvjw51vfTn9PjUi7/dVzYzoq4/3HpX2y/BFfNwQgJmhZAcgJxph1R23Jn350s/lHa72eBgBkD1pWAHJC6P+6yQrErADEBy0rAAAAkCb/AD20IuUG/pCdAAAAAElFTkSuQmCC"></mj-image>
              <mj-divider border-color="#A81B41" border-width="2px"></mj-divider>
              <mj-text font-size="22px" font-family="Silkscreen" font-weight="600" letter-spacing="-1px" color="#A81B41">Yes, Bro?</mj-text>
              <mj-text font-size="16px" line-height="24px" color="#27272a">
                欢迎申请加入 LITTLE RED BOOK，点击下方按钮进入注册页面并按照指示完成后续流程，并且请在20分钟内完成注册。
              </mj-text>
              <mj-button background-color="#A81B41" border-radius="8px" color="#f9fafb" font-weight="600" #{attrs}>完成注册</mj-button>
              <mj-text font-size="14px" color="#6b7280">
                不知道这是什么？那忽略本邮件就好啦！
              </mj-text>
              <mj-divider border-color="#A81B41" border-width="2px"></mj-divider>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
      """

    {:ok, html} = Mjml.to_html(mjml)

    html
  end

  # my current deployment platform cannot run the mjml nif due to an old version glibc
  # I'm just using the compiled mjml template directly for now
  defp render_registration_email_fallback(url) do
    attrs = Phoenix.HTML.attributes_escape(href: url) |> Phoenix.HTML.safe_to_string()

    """
    <!doctype html><html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"><head><title></title><!--[if !mso]><!--><meta http-equiv="X-UA-Compatible" content="IE=edge"><!--<![endif]--><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css">
    #outlook a { padding: 0; }
    body { margin: 0; padding: 0; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
    table, td { border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
    img { border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; -ms-interpolation-mode: bicubic; }
    p { display: block; margin: 13px 0; }
    </style>
    <!--[if mso]>
    <noscript>
    <xml>
    <o:OfficeDocumentSettings>
    <o:AllowPNG/>
    <o:PixelsPerInch>96</o:PixelsPerInch>
    </o:OfficeDocumentSettings>
    </xml>
    </noscript>
    <![endif]-->
    <!--[if lte mso 11]>
    <style type="text/css">
    .mj-outlook-group-fix { width:100% !important; }
    </style>
    <![endif]-->
    <!--[if !mso]><!--><link href="https://fonts.loli.net/css?family=Silkscreen" rel="stylesheet" type="text/css"><link href="https://fonts.loli.net/css?family=Inter" rel="stylesheet" type="text/css"><style type="text/css">@import url(https://fonts.loli.net/css?family=Silkscreen);@import url(https://fonts.loli.net/css?family=Inter);</style><!--<![endif]--><style type="text/css">@media only screen and (min-width:480px) { .mj-column-per-100 { width:100% !important; max-width:100%; }  }</style><style media="screen and (min-width:480px)">.moz-text-html .mj-column-per-100 { width:100% !important; max-width:100%; } </style><style type="text/css">@media only screen and (max-width:479px) {
                  table.mj-full-width-mobile { width: 100% !important; }
                  td.mj-full-width-mobile { width: auto !important; }
              }
              </style></head><body style="word-spacing:normal;"><div><!--[if mso | IE]><table border="0" cellpadding="0" cellspacing="0" role="presentation" align="center" width="600" style="width:600px;"><tr><td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;"><![endif]--><div style="margin:0px auto;max-width:600px;"><table border="0" cellpadding="0" cellspacing="0" role="presentation" align="center" style="width:100%;"><tbody><tr><td style="direction:ltr;font-size:0px;padding:20px 0;text-align:center;"><!--[if mso | IE]><table border="0" cellpadding="0" cellspacing="0" role="presentation"><tr><td style="vertical-align:top;width:600px;"><![endif]--><div class="mj-outlook-group-fix mj-column-per-100" style="font-size:0px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;"><table border="0" cellpadding="0" cellspacing="0" role="presentation" width="100%" style="vertical-align:top;"><tbody><tr><td align="center" style="font-size:0px;padding:10px 25px;word-break:break-word;"><table border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:collapse;border-spacing:0px;"><tbody><tr><td style="width:180px;"><img height="auto" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOsAAAAjCAYAAAB1sf0MAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAASKSURBVHgB7Z1PaNRAFMbfrC1WT3sq4ipuwYMWkR7EcxSPIj1ZV0FbFI+23hQUFQTFU/UoSrcHafViEY9i06t46KH45+SCroinPYgobTNOZnfaZDrJJtmk3eD3g/A6Sd5Msplk5s03SYkAAAAAAAAAAIDuhJlWXuo9yF175aoj0zsPDUp7/+InSsK1pwek/b30QdrDDz4zAgDEokAAgFzga+FUi3qif5dMH7lXlPb99Qalgcpv//mXaFkBiAlaVgByQk/YRhWjqpa2U5LGvAAAtKwA5IYe6mJm9liWMJZKV77ZtyP4ePexhY/9fK817HAaaufLODXO1O3JqbJV7FuhCYrANk5zp+v2orcMlU+Y30zZKtMKjVIUVqha+WHXouw6U7JGxUhEud1+BU5fRur2tL5+tmRNcEbFdv7cocWz3+25FyVraJXRMEXgzy+aHGvYsQdA9HoQRoI6krl/1Lqh1ztVt1Q60c2qBoqUFKOkHZ0UBqYsxtktT/p2Owfv/pzJ8TLbcWiYEbtA7amJZbLvDxXZNl+5gawSd30WtTJkPqGOK1TWzi0Q3sPtVp5tkcfA21dsIcotCDO9sTA2Lkb/yu38GeNVYeZWiYainkdfUfg0KEmlsKKWQTHryGb4R60ber1TdUul0Q0GICckalnXW8zdLZuOtAMACKarY9a0qNTtUWHchWZ2WWXR1fiitnHiY2J71bd/Mz5c04JFHFj1dmPO1OcHKGVEl/2YG19TioggYKFSn7dM29zYdrZ0jIeXz6sivhqjOGX28oFKzRxfu+WJJXHeCvH7G3V699pq53THjSHdGNMXHoljDMo7C38KwVC3AucgJLpZB899l1bFqkGxa1qTKQBIk6CHicv6wyQ7/6QgZgUgJyRqWT8802NVxK6dIgauL7Qkio3EkG58eRLtC5IZOBfyjOimecqobfRnQ4H+LemGtoDAYyIxmsqpqxHXpKgdf02EYvI6uLJOmO9/EbPmAzYaVNHiSDcaYfLQQuWbOZ5dK7cpyxj1aSXd0BYQdE55mHDefKB44l/DmEkQ6AYDkBNwswKQE9AN7hI2Q7oRI5XzFHHaXiuHxPJKloRJN15ZrkvxSX+udCOuy5Rpm07ozaq+8AAJBoCtB91gAHKCsWV98/OHtINLzckPR+519g0mhfqm05MHlIhO35bYLAzD8+vbAt66yEK60REjj9Pi4BZU2neMhjKSSDd8uTAhfIxdMYezh4w5DeVPCQmTbog8chSRrSz3DLXPlqypgKzlrKMM/AMpFGjO4XLCvsR7bqm8dbNVdPq2xGahD89r1Mj41kUm0o0Pr0TgPhjEMc6HlZFEuikQHxc1loz0OgNhs3+iEibdmOLZ1liArdLeKYEb903fP4yRr/KBJ39HPebW37ox3qyP3z3ypV+cvCvtif5+3/rTr29QHC4fvUIAgGQgZgUgJxi/bvjw51vfTn9PjUi7/dVzYzoq4/3HpX2y/BFfNwQgJmhZAcgJxph1R23Jn350s/lHa72eBgBkD1pWAHJC6P+6yQrErADEBy0rAAAAkCb/AD20IuUG/pCdAAAAAElFTkSuQmCC" width="180" style="border:0;display:block;outline:none;text-decoration:none;height:auto;width:100%;font-size:13px;" /></td></tr></tbody></table></td></tr><tr><td align="center" style="font-size:0px;padding:10px 25px;word-break:break-word;"><p style="border-top:solid 2px #A81B41;font-size:1px;margin:0px auto;width:100%;"></p><!--[if mso | IE]><table border="0" cellpadding="0" cellspacing="0" role="presentation" align="center" width="550px" style="border-top:solid 2px #A81B41;font-size:1px;margin:0px auto;width:550px;"><tr><td style="height:0;line-height:0;">&nbsp;</td></tr></table><![endif]--></td></tr><tr><td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;"><div style="font-family:Silkscreen;font-size:22px;font-weight:600;letter-spacing:-1px;line-height:1;text-align:left;color:#A81B41;">Yes, Bro?</div></td></tr><tr><td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;"><div style="font-family:Inter;font-size:16px;line-height:24px;text-align:left;color:#27272a;">
            欢迎申请加入 LITTLE RED BOOK，点击下方按钮进入注册页面并按照指示完成后续流程，并且请在20分钟内完成注册。
          </div></td></tr><tr><td align="center" vertical-align="middle" style="font-size:0px;padding:10px 25px;word-break:break-word;"><table border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:separate;line-height:100%;"><tbody><tr><td align="center" bgcolor="#A81B41" role="presentation" valign="middle" style="border:none;border-radius:8px;cursor:auto;mso-padding-alt:10px 25px;background:#A81B41;"><a #{attrs} target="_blank" style="display:inline-block;background:#A81B41;color:#f9fafb;font-family:Inter;font-size:13px;font-weight:600;line-height:120%;margin:0;text-decoration:none;text-transform:none;padding:10px 25px;mso-padding-alt:0px;border-radius:8px;">完成注册</a></td></tr></tbody></table></td></tr><tr><td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;"><div style="font-family:Inter;font-size:14px;line-height:1;text-align:left;color:#6b7280;">
            不知道这是什么？那忽略本邮件就好啦！
          </div></td></tr><tr><td align="center" style="font-size:0px;padding:10px 25px;word-break:break-word;"><p style="border-top:solid 2px #A81B41;font-size:1px;margin:0px auto;width:100%;"></p><!--[if mso | IE]><table border="0" cellpadding="0" cellspacing="0" role="presentation" align="center" width="550px" style="border-top:solid 2px #A81B41;font-size:1px;margin:0px auto;width:550px;"><tr><td style="height:0;line-height:0;">&nbsp;</td></tr></table><![endif]--></td></tr></tbody></table></div><!--[if mso | IE]></td></tr></table><![endif]--></td></tr></tbody></table></div><!--[if mso | IE]></td></tr></table><![endif]--></div></body></html>
    """
  end
end
