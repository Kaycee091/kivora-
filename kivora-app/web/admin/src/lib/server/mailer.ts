import nodemailer, { type Transporter } from 'nodemailer';
import { getEmailConfig } from './env';

let transporter: Transporter | null = null;

function getTransporter(): Transporter {
  if (!transporter) {
    const config = getEmailConfig();
    transporter = nodemailer.createTransport({
      host: config.host,
      port: config.port,
      // 465 = implicit TLS; 587/2525 = STARTTLS upgrade.
      secure: config.port === 465,
      auth: { user: config.user, pass: config.pass },
    });
  }
  return transporter;
}

export async function sendEmail(options: { to: string; subject: string; html: string; text: string }) {
  const { fromAddress, fromName } = getEmailConfig();
  await getTransporter().sendMail({
    from: { name: fromName, address: fromAddress },
    ...options,
  });
}

export async function verifySmtpConnection(): Promise<void> {
  await getTransporter().verify();
}

export function verificationEmail(code: string, expiresInMinutes: number) {
  const subject = 'Your Kivora verification code';
  const text = `Your Kivora verification code is ${code}. It expires in ${expiresInMinutes} minutes. If you didn't create a Kivora account, you can ignore this email.`;
  const html = `<div style="font-family: Arial, Helvetica, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px; color: #1f2937;">
  <h2 style="margin: 0 0 16px;">Verify your Kivora account</h2>
  <p style="margin: 0 0 16px;">Enter this code in the Kivora app to confirm your email address:</p>
  <p style="font-size: 32px; font-weight: bold; letter-spacing: 8px; margin: 0 0 16px; padding: 16px; background: #f3f4f6; border-radius: 8px; text-align: center;">${code}</p>
  <p style="margin: 0 0 8px; font-size: 14px; color: #6b7280;">This code expires in ${expiresInMinutes} minutes.</p>
  <p style="margin: 0; font-size: 14px; color: #6b7280;">If you didn't create a Kivora account, you can ignore this email.</p>
</div>`;
  return { subject, text, html };
}
