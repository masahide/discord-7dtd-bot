package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"regexp"
	"syscall"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/bwmarrin/discordgo"
	"github.com/k0kubun/pp"
	"github.com/kelseyhightower/envconfig"
)

var (
	env    Specification
	ec2svc = ec2.New(session.Must(session.NewSession()))
)

type Specification struct {
	DiscordToken string
	NameFilter   string `default:"7Dtd"`
}

func init() {
	err := envconfig.Process("", &env)
	if err != nil {
		log.Fatal(err.Error())
	}
}

func main() {

	// Create a new Discord session using the provided bot token.
	dg, err := discordgo.New("Bot " + env.DiscordToken)
	if err != nil {
		fmt.Println("error creating Discord session,", err)
		return
	}

	// Register the messageCreate func as a callback for MessageCreate events.
	dg.AddHandler(messageCreate)

	// Open a websocket connection to Discord and begin listening.
	err = dg.Open()
	if err != nil {
		fmt.Println("error opening connection,", err)
		return
	}

	// Wait here until CTRL-C or other term signal is received.
	fmt.Println("Bot is now running.  Press CTRL-C to exit.")
	sc := make(chan os.Signal, 1)
	signal.Notify(sc, syscall.SIGINT, syscall.SIGTERM, os.Interrupt, os.Kill)
	<-sc

	// Cleanly close down the Discord session.
	dg.Close()
}

func isMention(s *discordgo.Session, m *discordgo.MessageCreate) bool {
	for _, mention := range m.Mentions {
		if mention.ID == s.State.User.ID {
			return true
		}
	}
	return false
}

var (
	pingRe        = regexp.MustCompile(`^ping`)
	pongRe        = regexp.MustCompile(`^pong`)
	debugRe       = regexp.MustCompile(`^debug`)
	startServerRe = regexp.MustCompile(`^start server`)
)

// This function will be called (due to AddHandler above) every time a new
// message is created on any channel that the autenticated bot has access to.
func messageCreate(s *discordgo.Session, m *discordgo.MessageCreate) {

	if m.Author.ID == s.State.User.ID {
		return
	}
	if !isMention(s, m) {
		return
	}
	switch {
	case pingRe.MatchString(m.Content):
		s.ChannelMessageSend(m.ChannelID, "Pong!")
	case pongRe.MatchString(m.Content):
		s.ChannelMessageSend(m.ChannelID, "Ping!")
	case startServerRe.MatchString(m.Content):
		startServer(s, m)
	case debugRe.MatchString(m.Content):
		pp.Println("debug", m)
		s.ChannelMessageSend(m.ChannelID, "discord デバッグメッセージを出力したよ")
	}

}

func startServer(s *discordgo.Session, m *discordgo.MessageCreate) {
	in := &ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{&ec2.Filter{Name: aws.String("tag:Name"), Values: []*string{&env.NameFilter}}},
	}
	res, err := ec2svc.DescribeInstances(in)
	if err != nil {
		log.Printf("DescribeInstances err:%s", err)
		return
	}
	for _, r := range res.Reservations {
		for _, i := range r.Instances {
			if isIgnoreInstance(i) {
				log.Printf("ignore Instance: %s, state:%s", aws.StringValue(i.InstanceId), aws.StringValue(i.State.Name))
				continue
			}
			if isRunningInstance(i) {
				running(s, m, i)
				return
			}
			startInstance(s, m, i)
		}
	}
}

func startInstance(s *discordgo.Session, m *discordgo.MessageCreate, i *ec2.Instance) {
	res, err := ec2svc.StartInstances(&ec2.StartInstancesInput{
		InstanceIds: []*string{i.InstanceId},
	})
	if err != nil {
		log.Printf("startInstance err:%s instanceID:%s, state:%s", err, aws.StringValue(i.InstanceId), aws.StringValue(i.State.Name))
		s.ChannelMessageSendComplex(m.ChannelID, &discordgo.MessageSend{
			Tts: false,
			Embed: &discordgo.MessageEmbed{
				Title: "startInstance error",
				Description: fmt.Sprintf("%s\n instanceID:%s, state:%s",
					err,
					aws.StringValue(i.InstanceId),
					aws.StringValue(i.State.Name),
				),
			},
		})
		return
	}
	log.Printf("startInstance instanceID:%s, %s", aws.StringValue(i.InstanceId), res.GoString())
	s.ChannelMessageSendComplex(m.ChannelID, &discordgo.MessageSend{
		Tts: false,
		Embed: &discordgo.MessageEmbed{
			Title: "サーバーを起動しました",
			Description: fmt.Sprintf("起動中..\ninstanceID:%s\n%s",
				aws.StringValue(i.InstanceId),
				res.GoString(),
			),
		},
	})

}

func running(s *discordgo.Session, m *discordgo.MessageCreate, i *ec2.Instance) {
	ip := aws.StringValue(i.PublicIpAddress)
	if len(ip) == 0 {
		s.ChannelMessageSend(m.ChannelID,
			fmt.Sprintf("起動中です..\ninstanceID:%s,\nstate:%s",
				aws.StringValue(i.InstanceId),
				aws.StringValue(i.State.Name),
			))
		return
	}
	s.ChannelMessageSendComplex(m.ChannelID, &discordgo.MessageSend{
		Content: "サーバーIPアドレス",
		Tts:     false,
		Embed: &discordgo.MessageEmbed{
			Title: ip,
			Description: fmt.Sprintf("既に起動してます..\ninstanceID:%s\nstate:%s",
				aws.StringValue(i.InstanceId),
				aws.StringValue(i.State.Name),
			),
		},
	})
	return
}

func isIgnoreInstance(i *ec2.Instance) bool {
	switch aws.StringValue(i.State.Name) {
	case ec2.InstanceStateNameTerminated, ec2.InstanceStateNameShuttingDown:
		return true
	}
	return false
}

func isRunningInstance(i *ec2.Instance) bool {
	switch aws.StringValue(i.State.Name) {
	case ec2.InstanceStateNameRunning, ec2.InstanceStateNameStopping, ec2.InstanceStateNamePending:
		return true
	}
	return false
}

func sendMess(s *discordgo.Session, m *discordgo.MessageCreate) {
	//func (s *Session) ChannelMessageSendComplex(channelID string, data *MessageSend) (st *Message, err error)
	s.ChannelMessageSendComplex(m.ChannelID, &discordgo.MessageSend{
		Content: "サーバーIPアドレス",
		Tts:     false,
		Embed: &discordgo.MessageEmbed{
			Title:       "",
			Description: "既に起動してます",
		},
	})
}
